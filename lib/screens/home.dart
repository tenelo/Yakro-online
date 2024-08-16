import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.alwaysShow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Ma belle cité",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(193, 255, 255, 255)),
                  ),
                ],
              ),
              background: Image.asset(
                'assets/images/baseliqueC.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final location = locations[index];
                return GestureDetector(
                  onTap: (() {}),
                  child: LocationListItem(
                    imageUrl: location.imageUrl,
                    categorie: location.categorie,
                    sousTitre: location.sousTitre,
                    type: location.type,
                  ),
                );
              },
              childCount: locations.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ExampleParallax extends StatelessWidget {
  const ExampleParallax({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (final location in locations)
              LocationListItem(
                categorie: location.categorie,
                imageUrl: location.imageUrl,
                sousTitre: location.sousTitre,
                type: location.type,
              ),
          ],
        ),
      ),
    );
  }
}

class LocationListItem extends StatelessWidget {
  LocationListItem({
    super.key,
    required this.imageUrl,
    required this.sousTitre,
    required this.type,
    required this.categorie,
  });

  final String imageUrl;
  final String sousTitre;
  final String type;
  final String categorie;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: AspectRatio(
        aspectRatio: 17 / 7,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildGradient(),
              _buildTitleAndSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  // Image de fond
  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        Image.asset(
          imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  // Dégradé
  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  // Titre et sous-titre
  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categorie,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow
                .ellipsis, // Coupe le texte et ajoute des points de suspension
            maxLines: 1, // Limite le texte à une seule ligne
          ),
          Text(
            sousTitre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            overflow: TextOverflow
                .ellipsis, // Coupe le texte et ajoute des points de suspension
            maxLines: 1, // Limite le texte à une seule ligne
          ),
        ],
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
        (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
          Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required Widget background,
  }) : super(child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    // Force the background to take up all available width
    // and then scale its height based on the image's aspect ratio.
    final background = child!;
    final backgroundImageConstraints =
        BoxConstraints.tightFor(width: size.width);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    // Set the background's local offset, which is zero.
    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final background = child!;
    final backgroundParentData = background.parentData as ParallaxParentData;
    context.paintChild(background, backgroundParentData.offset + offset);
  }
}

class Location {
  const Location({
    required this.sousTitre,
    required this.categorie,
    required this.imageUrl,
    required this.type,
  });

  final String sousTitre;
  final String categorie;
  final String imageUrl;
  final String type;
}

const locations = [
  Location(
    sousTitre: 'Humburger , Chawarma...',
    categorie: 'Fast-Food',
    imageUrl: 'assets/images/burger2.jpeg',
    type: '',
  ),
  Location(
    sousTitre: 'Cuisine Ivoirienne',
    categorie: 'Restaurants',
    imageUrl: 'assets/images/plat2.png',
    type: '',
  ),
  Location(
    sousTitre: 'Alloco',
    categorie: 'Alloco',
    imageUrl: 'assets/images/alloco1.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Attiéké poisson',
    categorie: 'Attiéké',
    imageUrl: 'assets/images/plat3.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Coiffures Dames',
    categorie: 'Coiffures Dames',
    imageUrl: 'assets/images/coiff_dame2.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Coiffures Hommes',
    categorie: 'Coiffures Hommes',
    imageUrl: 'assets/images/coiff_homme.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Coutures Hommes , Dames ,sac à main,chaussures',
    categorie: 'Modes & Accessoires',
    imageUrl: 'assets/images/couture.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Pour vos dépannages',
    categorie: 'Mécaniciens',
    imageUrl: 'assets/images/mecano3.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Pour vos travaux de menuiseries',
    categorie: 'Menuiseries',
    imageUrl: 'assets/images/menuisier.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Pour vos travaux de maçonneries',
    categorie: 'Maçonneries',
    imageUrl: 'assets/images/brique2.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Hôtellerie',
    categorie: 'Hôtellerie',
    imageUrl: 'assets/images/hp1.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Résidences Meublées',
    categorie: 'Résidences',
    imageUrl: 'assets/images/meublee1.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Sites touristiques à visiter',
    categorie: 'Sites Touristiques',
    imageUrl: 'assets/images/sites1.jpeg',
    type: '',
  ),
  Location(
    sousTitre: 'Maisons à louer',
    categorie: 'Location de maison',
    imageUrl: 'assets/images/location.jpg',
    type: '',
  ),
  Location(
    sousTitre: 'Ventes de terrains',
    categorie: 'Terrains',
    imageUrl: 'assets/images/terrain2.jpg',
    type: '',
  ),
];
