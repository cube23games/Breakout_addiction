import '../domain/public_domain_verse.dart';
class PublicDomainVerseRepository {
  static const List<PublicDomainVerse> verses=<PublicDomainVerse>[
    PublicDomainVerse(reference:'Psalm 34:18',text:'Yahweh is near to those who have a broken heart, and saves those who have a crushed spirit.'),
    PublicDomainVerse(reference:'1 Corinthians 10:13',text:'No temptation has taken you except what is common to man. God is faithful, who will not allow you to be tempted above what you are able.'),
    PublicDomainVerse(reference:'Philippians 4:8',text:'Whatever things are true, whatever things are honorable, whatever things are just, whatever things are pure, think about these things.'),
    PublicDomainVerse(reference:'Galatians 6:2',text:'Bear one another’s burdens, and so fulfill the law of Christ.'),
    PublicDomainVerse(reference:'Romans 12:2',text:'Be transformed by the renewing of your mind, so that you may prove what is the good, well-pleasing, and perfect will of God.'),
    PublicDomainVerse(reference:'Proverbs 4:23',text:'Keep your heart with all diligence, for out of it is the wellspring of life.'),
    PublicDomainVerse(reference:'James 5:16',text:'Confess your offenses to one another, and pray for one another, that you may be healed.'),
  ];
  PublicDomainVerse forDay(int dayNumber) {
    final normalized = dayNumber < 1 ? 0 : dayNumber - 1;
    return verses[normalized % verses.length];
  }
}
