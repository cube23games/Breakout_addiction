#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path.cwd()
MANIFEST = ROOT / 'tools' / 'ba70_shadow_manifest.json'
RESULTS = Path(os.environ.get('RUNNER_TEMP', '/tmp')) / 'ba70-shadow-results'
WORKTREES = Path(os.environ.get('RUNNER_TEMP', '/tmp')) / 'ba70-shadow-worktrees'
BASE_VERIFIERS = [
    'tools/verify_ba56.py',
    'tools/verify_ba56a.py',
    'tools/verify_ba56b.py',
    'tools/verify_ba56g.py',
    'tools/verify_ba57_58.py',
    *[f'tools/verify_ba{n}.py' for n in range(59, 70)],
]


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def run_capture(
    args: list[str], cwd: Path, log: Path,
    extra_env: dict[str, str] | None = None,
) -> dict:
    log.parent.mkdir(parents=True, exist_ok=True)
    started = now()
    result = subprocess.run(
        args,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env={
            **os.environ,
            'PYTHONDONTWRITEBYTECODE': '1',
            **(extra_env or {}),
        },
    )
    output = result.stdout or ''
    log.write_text(output, encoding='utf-8')
    return {
        'command': args,
        'exit_code': result.returncode,
        'passed': result.returncode == 0,
        'started_utc': started,
        'finished_utc': now(),
        'log': str(log.relative_to(RESULTS)),
        'highlights': extract_highlights(output),
    }


def extract_highlights(output: str, limit: int = 80) -> list[str]:
    needles = (
        'error •', 'warning •', 'info •', 'Expected:', 'Actual:',
        'Test failed', 'Some tests failed', 'Exception:', 'Error:',
        'FAILED', 'FAIL:', 'No issues found', 'All tests passed',
    )
    lines = [line.rstrip() for line in output.splitlines()]
    picked = [line for line in lines if any(n in line for n in needles)]
    if not picked and lines:
        picked = lines[-20:]
    return picked[:limit]


def verifiers_for(number: int) -> list[str]:
    return [*BASE_VERIFIERS, *[f'tools/verify_ba70a{n}.py' for n in range(1, number + 1)]]


def add_worktree(label: str, sha: str) -> Path:
    path = WORKTREES / label.lower().replace('/', '_')
    if path.exists():
        shutil.rmtree(path)
    subprocess.run(['git', 'worktree', 'prune'], cwd=ROOT, check=False)
    result = subprocess.run(
        ['git', 'worktree', 'add', '--detach', str(path), sha],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if result.returncode != 0:
        raise RuntimeError(f'Unable to create worktree for {label} at {sha}:\n{result.stdout}')
    return path


def remove_worktree(path: Path) -> None:
    subprocess.run(['git', 'worktree', 'remove', '--force', str(path)], cwd=ROOT, check=False)
    shutil.rmtree(path, ignore_errors=True)


def test_tree(label: str, sha: str, number: int) -> dict:
    print(f'=== SHADOW CHECK {label} {sha} ===', flush=True)
    worktree = add_worktree(label, sha)
    stage_dir = RESULTS / 'stages' / label
    record = {
        'label': label,
        'sha': sha,
        'stage_number': number,
        'started_utc': now(),
        'commands': {},
        'verifiers': [],
    }
    try:
        record['commands']['pub_get'] = run_capture(
            ['flutter', 'pub', 'get'], worktree, stage_dir / 'flutter_pub_get.log'
        )
        record['commands']['analyze'] = run_capture(
            ['flutter', 'analyze', '--no-fatal-infos'],
            worktree,
            stage_dir / 'flutter_analyze.log',
        )
        record['commands']['test'] = run_capture(
            ['flutter', 'test'], worktree, stage_dir / 'flutter_test.log'
        )
        for relative in verifiers_for(number):
            verifier = worktree / relative
            if not verifier.is_file():
                result = {
                    'path': relative,
                    'exit_code': 127,
                    'passed': False,
                    'log': None,
                    'highlights': [f'Missing verifier: {relative}'],
                }
            else:
                command = run_capture(
                    [sys.executable, str(verifier)],
                    worktree,
                    stage_dir / 'verifiers' / f'{Path(relative).stem}.log',
                )
                result = {'path': relative, **command}
            record['verifiers'].append(result)
        record['passed'] = (
            all(item['passed'] for item in record['commands'].values())
            and all(item['passed'] for item in record['verifiers'])
        )
        status = subprocess.run(
            ['git', 'status', '--porcelain=v1', '--untracked-files=all'],
            cwd=worktree,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        (stage_dir / 'git_status_after_checks.txt').write_text(
            status.stdout or '', encoding='utf-8'
        )
    except Exception as exc:
        record['passed'] = False
        record['internal_error'] = f'{type(exc).__name__}: {exc}'
        (stage_dir / 'INTERNAL_ERROR.txt').write_text(
            traceback.format_exc(), encoding='utf-8'
        )
    finally:
        record['finished_utc'] = now()
        remove_worktree(worktree)
    return record


def android_simulation(final_sha: str) -> dict:
    label = 'FINAL_ANDROID_SIMULATION'
    print(f'=== {label} {final_sha} ===', flush=True)
    worktree = add_worktree(label, final_sha)
    out = RESULTS / 'android_simulation'
    record = {'label': label, 'sha': final_sha, 'commands': {}}
    commands = [
        ('flutter_create', ['flutter', 'create', '--platforms=android', '--project-name', 'breakout_addiction', '.']),
        ('patch_notifications', [sys.executable, 'tools/patch_android_notifications.py']),
        ('patch_release_security', [sys.executable, 'tools/patch_android_release_security.py', '--channel', 'qa']),
        ('patch_screen_protection', [sys.executable, 'tools/patch_android_screen_protection.py']),
        ('patch_widget', [sys.executable, 'tools/patch_android_widget.py']),
        ('launcher_icons', ['dart', 'run', 'flutter_launcher_icons']),
    ]
    try:
        shutil.rmtree(worktree / 'android', ignore_errors=True)
        shadow_key = worktree / '.ba70-shadow-signing-placeholder.p12'
        shadow_key.write_bytes(b'BA70 shadow CI placeholder; never used to build.')
        signing_env = {
            'BREAKOUT_APP_SIGNING_KEYSTORE_PATH': str(shadow_key),
            'BREAKOUT_APP_SIGNING_STORE_PASSWORD': 'shadow-ci-only',
            'BREAKOUT_APP_SIGNING_KEY_PASSWORD': 'shadow-ci-only',
            'BREAKOUT_APP_SIGNING_KEY_ALIAS': 'shadow-ci-only',
        }
        for name, args in commands:
            if args[0] == sys.executable and not (worktree / args[1]).is_file():
                record['commands'][name] = {
                    'command': args,
                    'exit_code': 127,
                    'passed': False,
                    'log': None,
                    'highlights': [f'Missing script: {args[1]}'],
                }
                continue
            record['commands'][name] = run_capture(
                args,
                worktree,
                out / f'{name}.log',
                signing_env if name == 'patch_release_security' else None,
            )
        record['passed'] = all(item['passed'] for item in record['commands'].values())
        expected = [
            worktree / 'android' / 'app' / 'src' / 'main' / 'AndroidManifest.xml',
            worktree / 'android' / 'app' / 'src' / 'main' / 'kotlin',
        ]
        record['generated_checks'] = {
            str(path.relative_to(worktree)): path.exists() for path in expected
        }
        if not all(record['generated_checks'].values()):
            record['passed'] = False
    except Exception as exc:
        record['passed'] = False
        record['internal_error'] = f'{type(exc).__name__}: {exc}'
        (out / 'INTERNAL_ERROR.txt').write_text(traceback.format_exc(), encoding='utf-8')
    finally:
        remove_worktree(worktree)
    return record


def write_summary(data: dict) -> None:
    lines = [
        '# BA-70 Shadow CI Results', '',
        f"Generated: {data['generated_utc']}",
        f"Overall: {'PASS' if data['overall_pass'] else 'FAIL'}", '',
        '| Tree | Pub get | Analyze | Tests | Verifiers | Result |',
        '|---|---:|---:|---:|---:|---:|',
    ]
    for stage in data['stage_results']:
        commands = stage.get('commands', {})
        verifier_pass = all(item.get('passed') for item in stage.get('verifiers', []))
        cell = lambda name: 'PASS' if commands.get(name, {}).get('passed') else 'FAIL'
        lines.append(
            f"| {stage['label']} | {cell('pub_get')} | {cell('analyze')} | "
            f"{cell('test')} | {'PASS' if verifier_pass else 'FAIL'} | "
            f"{'PASS' if stage.get('passed') else 'FAIL'} |"
        )
    android = data['android_simulation']
    lines.extend(['', f"Android simulation: {'PASS' if android.get('passed') else 'FAIL'}", ''])
    if not data['overall_pass']:
        lines.append('## Consolidated failures')
        for stage in data['stage_results']:
            if stage.get('passed'):
                continue
            lines.append(f"\n### {stage['label']} — {stage['sha']}")
            for name, command in stage.get('commands', {}).items():
                if command.get('passed'):
                    continue
                lines.append(f"- {name}: exit {command.get('exit_code')}")
                for highlight in command.get('highlights', [])[:20]:
                    lines.append(f"  - `{highlight}`")
            failed_verifiers = [v for v in stage.get('verifiers', []) if not v.get('passed')]
            for verifier in failed_verifiers:
                lines.append(f"- verifier {verifier['path']}: exit {verifier.get('exit_code')}")
                for highlight in verifier.get('highlights', [])[:10]:
                    lines.append(f"  - `{highlight}`")
        if not android.get('passed'):
            lines.append('\n### Final Android simulation')
            for name, command in android.get('commands', {}).items():
                if command.get('passed'):
                    continue
                lines.append(f"- {name}: exit {command.get('exit_code')}")
                for highlight in command.get('highlights', [])[:20]:
                    lines.append(f"  - `{highlight}`")
    (RESULTS / 'SUMMARY.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    failures = [line for line in lines if line.startswith('- ') or line.startswith('  - ')]
    (RESULTS / 'FAILURES.txt').write_text('\n'.join(failures) + ('\n' if failures else ''), encoding='utf-8')


def main() -> int:
    shutil.rmtree(RESULTS, ignore_errors=True)
    shutil.rmtree(WORKTREES, ignore_errors=True)
    RESULTS.mkdir(parents=True)
    WORKTREES.mkdir(parents=True)
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    (RESULTS / 'commit_manifest.json').write_text(
        json.dumps(manifest, indent=2) + '\n', encoding='utf-8'
    )
    env = {
        'generated_utc': now(),
        'github_run_id': os.environ.get('GITHUB_RUN_ID'),
        'github_sha': os.environ.get('GITHUB_SHA'),
        'github_ref': os.environ.get('GITHUB_REF'),
    }
    version = subprocess.run(
        ['flutter', '--version'], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    env['flutter_version'] = version.stdout or ''
    (RESULTS / 'environment.json').write_text(json.dumps(env, indent=2) + '\n')

    records = []
    for stage in manifest['stages']:
        records.append(test_tree(stage['stage_id'], stage['commit_sha'], stage['number']))
    final = manifest['stages'][-1]
    records.append(test_tree('FINAL_COMBINED_A13', final['commit_sha'], final['number']))
    android = android_simulation(final['commit_sha'])
    overall = all(item.get('passed') for item in records) and android.get('passed', False)
    data = {
        'generated_utc': now(),
        'overall_pass': overall,
        'stage_results': records,
        'android_simulation': android,
    }
    (RESULTS / 'summary.json').write_text(json.dumps(data, indent=2) + '\n')
    write_summary(data)
    (RESULTS / ('PASS' if overall else 'FAIL')).write_text(now() + '\n')
    print((RESULTS / 'SUMMARY.md').read_text(), flush=True)
    return 0


if __name__ == '__main__':
    try:
        exit_code = main()
    except Exception:
        RESULTS.mkdir(parents=True, exist_ok=True)
        (RESULTS / 'SHADOW_SCRIPT_CRASH.txt').write_text(traceback.format_exc(), encoding='utf-8')
        (RESULTS / 'FAIL').write_text(now() + '\n')
        raise
    raise SystemExit(exit_code)
