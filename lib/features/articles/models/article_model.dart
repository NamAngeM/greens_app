import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String content;
  final List<String> tags;
  final DateTime publishDate;
  final List<String> relatedProductCategories;
  final List<String> relatedEnvironmentalTopics;
  final bool isPremium;
  final int readTimeMinutes;
  final Map<String, dynamic>? additionalData;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.content,
    required this.tags,
    required this.publishDate,
    this.relatedProductCategories = const [],
    this.relatedEnvironmentalTopics = const [],
    this.isPremium = false,
    this.readTimeMinutes = 5,
    this.additionalData,
  });

  // Méthode pour déterminer si un article est lié à une catégorie de produit
  bool isRelatedToProductCategory(String category) {
    return relatedProductCategories.any(
      (cat) => cat.toLowerCase() == category.toLowerCase(),
    );
  }

  // Méthode pour déterminer si un article est lié à un sujet environnemental
  bool isRelatedToEnvironmentalTopic(String topic) {
    return relatedEnvironmentalTopics.any(
      (t) => t.toLowerCase() == topic.toLowerCase(),
    );
  }

  // Méthode pour créer une copie d'un article avec certaines valeurs modifiées
  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    String? content,
    List<String>? tags,
    DateTime? publishDate,
    List<String>? relatedProductCategories,
    List<String>? relatedEnvironmentalTopics,
    bool? isPremium,
    int? readTimeMinutes,
    Map<String, dynamic>? additionalData,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      publishDate: publishDate ?? this.publishDate,
      relatedProductCategories: relatedProductCategories ?? this.relatedProductCategories,
      relatedEnvironmentalTopics: relatedEnvironmentalTopics ?? this.relatedEnvironmentalTopics,
      isPremium: isPremium ?? this.isPremium,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Méthode pour convertir l'article en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'content': content,
      'tags': tags,
      'publishDate': publishDate.millisecondsSinceEpoch,
      'relatedProductCategories': relatedProductCategories,
      'relatedEnvironmentalTopics': relatedEnvironmentalTopics,
      'isPremium': isPremium,
      'readTimeMinutes': readTimeMinutes,
      'additionalData': additionalData,
    };
  }

  // Méthode pour créer un article à partir d'une Map
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      content: map['content'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      publishDate: DateTime.fromMillisecondsSinceEpoch(map['publishDate'] ?? DateTime.now().millisecondsSinceEpoch),
      relatedProductCategories: List<String>.from(map['relatedProductCategories'] ?? []),
      relatedEnvironmentalTopics: List<String>.from(map['relatedEnvironmentalTopics'] ?? []),
      isPremium: map['isPremium'] ?? false,
      readTimeMinutes: map['readTimeMinutes'] ?? 5,
      additionalData: map['additionalData'],
    );
  }

  // Méthode pour générer un article de démonstration sur le plastique
  factory Article.plasticOceanArticle() {
    return Article(
      id: 'plastic-ocean-impact',
      title: 'Le plastique et les océans : une menace grandissante',
      summary: 'Découvrez l\'impact alarmant du plastique sur nos océans et les écosystèmes marins, ainsi que les solutions pour inverser la tendance.',
      imageUrl: 'https://images.unsplash.com/photo-1483683804023-6ccdb62f86ef',
      content: '''
# Le plastique et les océans : une menace grandissante

Chaque année, plus de 8 millions de tonnes de plastique se déversent dans nos océans, menaçant la vie marine et les écosystèmes dont nous dépendons tous.

## L'ampleur du problème

La production mondiale de plastique a atteint 368 millions de tonnes en 2019. Le plastique représente 80% des déchets marins, et ce chiffre ne cesse d'augmenter.

### Impact sur la vie marine
- Plus de 700 espèces marines sont affectées par le plastique
- 100 000 mammifères marins meurent chaque année à cause du plastique
- Les microplastiques sont désormais présents dans toute la chaîne alimentaire marine

## Pourquoi est-ce si grave ?

Le plastique ne se dégrade pas naturellement - il se fragmente en microplastiques qui persistent pendant des centaines d'années. Ces microplastiques :
- Sont ingérés par les poissons et crustacés
- Remontent la chaîne alimentaire jusqu'à nos assiettes
- Contiennent des produits chimiques toxiques qui s'accumulent dans les tissus

## Solutions individuelles

1. **Réduire** votre consommation de plastique à usage unique
2. **Participer** à des nettoyages de plages et rivières
3. **Privilégier** les produits sans emballage plastique
4. **Sensibiliser** votre entourage à cette problématique
5. **Soutenir** les législations contre la pollution plastique

## Innovations technologiques

Plusieurs initiatives innovantes luttent contre cette pollution :
- The Ocean Cleanup : système de barrières flottantes pour capturer le plastique
- Plastique biodégradable à base d'algues
- Enzymes mangeuses de plastique pour accélérer la décomposition

## Agir maintenant

La pollution plastique est un problème urgent qui nécessite une action immédiate. En modifiant nos habitudes de consommation et en soutenant des initiatives de nettoyage et de prévention, nous pouvons contribuer à inverser cette tendance alarmante.

N'oubliez pas : chaque geste compte dans la protection de nos océans !
''',
      tags: ['Plastique', 'Océans', 'Pollution', 'Environnement', 'Recyclage'],
      publishDate: DateTime.now().subtract(const Duration(days: 30)),
      relatedProductCategories: ['Plastique', 'Emballage', 'Bouteilles', 'Produits jetables'],
      relatedEnvironmentalTopics: ['Pollution marine', 'Recyclage', 'Réduction des déchets'],
      readTimeMinutes: 8,
      additionalData: {
        'sourcesUrl': 'https://www.unep.org/interactive/beat-plastic-pollution/',
        'videoUrl': 'https://www.youtube.com/watch?v=HQTUWK7CM-Y',
        'audioAvailable': true,
      },
    );
  }

  // Méthode pour générer un article sur la pollution numérique
  factory Article.digitalPollutionArticle() {
    return Article(
      id: 'digital-pollution-impact',
      title: 'La pollution numérique : l\'impact caché de nos appareils connectés',
      summary: 'Explorez l\'empreinte écologique invisible mais grandissante de notre vie numérique et découvrez comment la réduire efficacement.',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c',
      content: '''
# La pollution numérique : l'impact caché de nos appareils connectés

Notre monde connecté a révolutionné nos vies, mais cette révolution numérique a un coût environnemental souvent invisible et pourtant bien réel.

## Qu'est-ce que la pollution numérique ?

La pollution numérique englobe toutes les émissions de gaz à effet de serre et la consommation de ressources liées à :
- La fabrication des appareils électroniques
- L'utilisation quotidienne d'internet et des services numériques
- L'hébergement et le fonctionnement des centres de données
- La fin de vie des équipements électroniques

## Des chiffres alarmants

- Le numérique représente 4% des émissions mondiales de gaz à effet de serre
- Cette empreinte pourrait doubler d'ici 2025
- Regarder une heure de vidéo en streaming HD émet environ 0,08 kg de CO2
- La fabrication d'un smartphone génère environ 80% de son empreinte carbone totale

## L'impact du streaming vidéo

Le streaming vidéo représente plus de 60% du trafic internet mondial. Voici son impact :
- 1 heure de streaming HD = 1,6 km en voiture en termes d'émissions
- La résolution 4K consomme jusqu'à 4 fois plus de données que la HD
- Les services de streaming vidéo émettent autant de CO2 que l'Espagne chaque année

## Les emails et le cloud

- Un email avec pièce jointe émet environ 35 grammes de CO2
- Un utilisateur professionnel reçoit en moyenne 121 emails par jour
- Les centres de données consomment 2% de l'électricité mondiale

## Solutions pratiques pour réduire votre pollution numérique

1. **Prolongez** la durée de vie de vos appareils (la fabrication est la phase la plus polluante)
2. **Réduisez** la qualité des vidéos en streaming quand la HD n'est pas nécessaire
3. **Nettoyez** régulièrement votre boîte mail et vos stockages cloud
4. **Privilégiez** le Wi-Fi plutôt que la 4G/5G (moins énergivore)
5. **Activez** le mode sombre sur vos applications (économie d'énergie sur écrans OLED)
6. **Utilisez** des moteurs de recherche écologiques (Ecosia, Lilo, etc.)

## Vers un numérique plus responsable

La prise de conscience collective et les initiatives pour un numérique plus durable se multiplient :
- Écoconception des sites web et applications
- Centres de données alimentés par des énergies renouvelables
- Économie circulaire des appareils électroniques

## Conclusion

Notre vie numérique a un impact environnemental bien réel, mais des solutions existent. En adoptant quelques gestes simples au quotidien, nous pouvons tous contribuer à réduire notre pollution numérique tout en continuant à profiter des avantages du monde connecté.
''',
      tags: ['Numérique', 'Pollution', 'Écologie', 'Internet', 'Empreinte carbone'],
      publishDate: DateTime.now().subtract(const Duration(days: 15)),
      relatedProductCategories: ['Électronique', 'Smartphones', 'Ordinateurs', 'Objets connectés'],
      relatedEnvironmentalTopics: ['Empreinte carbone', 'Consommation énergétique', 'Déchets électroniques'],
      readTimeMinutes: 10,
      additionalData: {
        'sourcesUrl': 'https://theshiftproject.org/article/climat-insoutenable-usage-video/',
        'videoUrl': 'https://www.youtube.com/watch?v=JJn6pja_l8s',
        'audioAvailable': true,
      },
    );
  }

  // Méthode pour générer un article sur la pollution sonore
  factory Article.noisePollutionArticle() {
    return Article(
      id: 'noise-pollution-health',
      title: 'Pollution sonore : un danger invisible pour notre santé',
      summary: 'Comment le bruit de notre environnement moderne affecte notre santé physique et mentale, et les moyens de s\'en protéger.',
      imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad',
      content: '''
# Pollution sonore : un danger invisible pour notre santé

Dans notre monde moderne, le bruit est omniprésent - trafic, chantiers, voisinage, musique... Cette pollution sonore n'est pas qu'une simple nuisance : elle constitue un véritable enjeu de santé publique.

## Un problème sous-estimé

Selon l'Organisation Mondiale de la Santé, la pollution sonore est le deuxième facteur environnemental le plus nocif pour la santé après la pollution atmosphérique. En Europe, elle contribuerait à :
- 12 000 décès prématurés par an
- 48 000 cas de maladies cardiaques
- Des troubles cognitifs chez 12 500 enfants

## Les impacts sur notre santé

### Effets auditifs
- Perte auditive temporaire ou permanente
- Acouphènes (sifflements ou bourdonnements persistants)
- Hyperacousie (hypersensibilité aux sons)

### Effets non-auditifs
- Troubles du sommeil
- Stress et anxiété
- Augmentation de la pression artérielle
- Risques cardiovasculaires accrus
- Difficultés d'apprentissage chez les enfants
- Baisse de la productivité

## Les sources principales de pollution sonore

1. **Transport** : trafic routier, trains, avions
2. **Activités industrielles et chantiers**
3. **Loisirs** : concerts, discothèques, écouteurs
4. **Équipements domestiques** : électroménager, ventilation
5. **Voisinage** : conversations, musique, animaux

## Mesurer et comprendre le bruit

Le bruit se mesure en décibels (dB) :
- 0 dB : seuil d'audition
- 30 dB : chuchotement
- 60 dB : conversation normale
- 85 dB : seuil de danger pour l'audition
- 120 dB : seuil de douleur

L'exposition répétée ou prolongée à des niveaux supérieurs à 85 dB peut endommager l'audition de façon permanente.

## Comment se protéger de la pollution sonore

### À la maison
- Isoler acoustiquement son logement
- Utiliser des matériaux absorbants (tapis, rideaux épais)
- Privilégier les appareils électroménagers silencieux
- Aménager des "zones calmes" dans son intérieur

### À l'extérieur
- Utiliser des protections auditives dans les environnements bruyants
- Limiter l'utilisation des écouteurs et respecter la règle 60/60 (pas plus de 60% du volume maximum pendant 60 minutes)
- Faire des pauses sonores régulières dans des lieux calmes
- S'éloigner des sources de bruit intense

### Au niveau collectif
- Soutenir les politiques de réduction du bruit
- Privilégier les transports silencieux (vélo, véhicules électriques)
- Respecter la tranquillité de son voisinage

## Conclusion

La pollution sonore est un problème de santé publique majeur qui mérite notre attention. En comprenant ses dangers et en adoptant des mesures de protection, nous pouvons préserver notre bien-être auditif et notre santé globale dans un monde de plus en plus bruyant.
''',
      tags: ['Pollution sonore', 'Santé', 'Environnement', 'Bruit', 'Audition'],
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      relatedProductCategories: ['Écouteurs', 'Casques audio', 'Appareils électroniques', 'Isolation phonique'],
      relatedEnvironmentalTopics: ['Santé environnementale', 'Urbanisme', 'Bien-être'],
      readTimeMinutes: 9,
      additionalData: {
        'sourcesUrl': 'https://www.who.int/europe/news-room/fact-sheets/item/noise',
        'videoUrl': 'https://www.youtube.com/watch?v=nEZ8QdHHveI',
        'audioAvailable': true,
      },
    );
  }

  // Liste d'articles de démonstration
  static List<Article> getDemoArticles() {
    return [
      Article.plasticOceanArticle(),
      Article.digitalPollutionArticle(),
      Article.noisePollutionArticle(),
      Article(
        id: 'sustainable-fashion',
        title: 'Mode durable : repenser notre façon de nous habiller',
        summary: 'L\'industrie textile est l\'une des plus polluantes au monde. Découvrez comment faire des choix plus écologiques.',
        imageUrl: 'https://images.unsplash.com/photo-1556905200-279565513a2d',
        content: 'Contenu sur la mode durable...',
        tags: ['Mode', 'Textile', 'Consommation', 'Recyclage'],
        publishDate: DateTime.now().subtract(const Duration(days: 20)),
        relatedProductCategories: ['Vêtements', 'Textile', 'Accessoires'],
        relatedEnvironmentalTopics: ['Fast fashion', 'Éthique', 'Recyclage'],
        readTimeMinutes: 7,
      ),
      Article(
        id: 'water-conservation',
        title: 'Économiser l\'eau au quotidien : gestes simples et impacts majeurs',
        summary: 'L\'eau est une ressource précieuse. Voici comment réduire votre consommation avec des gestes simples.',
        imageUrl: 'https://images.unsplash.com/photo-1527069438173-5e1fe8be8428',
        content: 'Contenu sur l\'économie d\'eau...',
        tags: ['Eau', 'Économie', 'Ressources', 'Écogestes'],
        publishDate: DateTime.now().subtract(const Duration(days: 45)),
        relatedProductCategories: ['Produits ménagers', 'Salle de bain', 'Jardinage'],
        relatedEnvironmentalTopics: ['Ressources en eau', 'Sécheresse', 'Économie d\'énergie'],
        readTimeMinutes: 6,
      ),
    ];
  }
} 