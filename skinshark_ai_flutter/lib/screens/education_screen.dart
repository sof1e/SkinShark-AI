import 'package:skinshark_ai_fixed/utils/imports.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _abcdeKey = GlobalKey();
  final GlobalKey _cancerousKey = GlobalKey();
  final GlobalKey _nonCancerousKey = GlobalKey();
  final GlobalKey _inflammatoryKey = GlobalKey();
  final GlobalKey _fungalKey = GlobalKey();
  final GlobalKey _viralKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showArticleDetails(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(content),
                ],
              ),
            ),
          ),
    );
  }

  void _showMarkdownArticle(
    BuildContext context,
    String title,
    String assetPath,
  ) async {
    final content = await DefaultAssetBundle.of(context).loadString(assetPath);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Markdown(
                    data: content,
                    controller: scrollController,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      p: const TextStyle(fontSize: 16),
                    ),
                    imageBuilder: (uri, title, alt) {
                      return Image.asset(uri.toString());
                    },
                  ),
                ),
          ),
    );
  }

  Future<void> _loadAndShowArticle(String title, String assetPath) async {
    final content = await DefaultAssetBundle.of(context).loadString(assetPath);
    _showArticleDetails(context, title, content);
  }

  Widget conditionCard(
    String imagePath,
    String title,
    String description,
    String markdownPath,
  ) {
    return ListTile(
      leading: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showMarkdownArticle(context, title, markdownPath);
      },
    );
  }

  Widget section(GlobalKey key, String title, List<Widget> contentCards) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ...contentCards,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text("Education  "),
            Icon(Icons.menu_book, color: secondaryColor),
          ],
        ),
        backgroundColor: backgroundColor,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        shadowColor: secondaryColor,
      ),
      body: Column(
        children: [
          // Scroll buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: [
                FilterButton(
                  label: "ABCDE",
                  onTap: () => scrollToSection(_abcdeKey),
                ),
                FilterButton(
                  label: "Cancerous",
                  onTap: () => scrollToSection(_cancerousKey),
                ),
                FilterButton(
                  label: "Non-Cancerous",
                  onTap: () => scrollToSection(_nonCancerousKey),
                ),
                FilterButton(
                  label: "Inflammatory",
                  onTap: () => scrollToSection(_inflammatoryKey),
                ),
                FilterButton(
                  label: "Fungal",
                  onTap: () => scrollToSection(_fungalKey),
                ),
                FilterButton(
                  label: "Viral",
                  onTap: () => scrollToSection(_viralKey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section(_abcdeKey, "Guide to Skin Cancer", [
                    conditionCard(
                      "assets/images/abcde.jpg",
                      "Spotting Skin Cancer Early: The ABCDE Method Explained",
                      "A serious form of skin cancer that can spread quickly.",
                      "assets/articles/abcde.md",
                    ),
                    conditionCard(
                      "assets/images/mole.jpg",
                      "Moles",
                      "Common skin cancer usually due to sun exposure.",
                      "assets/articles/mole.md",
                    ),
                  ]),
                  section(_cancerousKey, "Cancerous Conditions", [
                    conditionCard(
                      "assets/images/melanoma.jpg",
                      "Melanoma",
                      "A serious form of skin cancer that can spread quickly.",
                      "assets/articles/melanoma.md",
                    ),

                    conditionCard(
                      "assets/images/bcc.png",
                      "Basal Cell Carcinoma",
                      "Common skin cancer usually due to sun exposure.",
                      "assets/articles/bcc.md",
                    ),
                    conditionCard(
                      "assets/images/mcc.jpg",
                      "Merkel Cell Carcinoma",
                      "A serious form of skin cancer that can spread quickly.",
                      "assets/articles/mcc.md",
                    ),
                  ]),
                  section(_nonCancerousKey, "Non-Cancerous Conditions", [
                    conditionCard(
                      "assets/images/acne.jpg",
                      "Acne",
                      "Occurs when pores get clogged, leading to various breakouts.",
                      "assets/articles/acne.md",
                    ),
                    conditionCard(
                      "assets/images/eczema.jpg",
                      "Eczema",
                      "Causes itching, redness, and inflammation.",
                      "assets/articles/eczema.md",
                    ),
                    conditionCard(
                      "assets/images/psoriasis.jpg",
                      "Psoriasis",
                      "Speeds up skin cell production causing thick, scaly patches.",
                      "assets/articles/psoriasis.md",
                    ),
                    conditionCard(
                      "assets/images/rosacea.jpg",
                      "Rosacea",
                      "Facial redness, breakouts, and visible vessels.",
                      "assets/articles/rosacea.md",
                    ),
                  ]),
                  section(_inflammatoryKey, "Inflammatory Conditions", [
                    conditionCard(
                      "assets/images/dermatitis.jpg",
                      "Dermatitis",
                      "Red, itchy rash caused by skin irritation or allergy.",
                      "assets/articles/dermatitis.md",
                    ),
                    conditionCard(
                      "assets/images/lupus.jpg",
                      "Lupus",
                      "Autoimmune disease affecting skin and internal organs.",
                      "assets/articles/lupus.md",
                    ),
                  ]),
                  section(_fungalKey, "Fungal Infections", [
                    conditionCard(
                      "assets/images/ringworm.jpg",
                      "Ringworm",
                      "Circular, itchy rash caused by a fungal infection.",
                      "assets/articles/ringworm.md",
                    ),
                    conditionCard(
                      "assets/images/athletes_foot.png",
                      "Athlete’s Foot",
                      "Common fungal infection between toes.",
                      "assets/articles/athletes_foot.md",
                    ),
                    conditionCard(
                      "assets/images/candidasis.jpg",
                      "Candidiasis",
                      "Fungal infection that affects the skin, mouth, or genitals and is characterized by itching, redness, and a discharge",
                      "assets/articles/candidasis.md",
                    ),
                  ]),
                  section(_viralKey, "Viral Infections", [
                    conditionCard(
                      "assets/images/herpes.jpg",
                      "Herpes",
                      "Blisters caused by herpes simplex virus.",
                      "assets/articles/herpes.md",
                    ),
                    conditionCard(
                      "assets/images/warts.jpg",
                      "Warts",
                      "Growths caused by human papillomavirus.",
                      "assets/articles/warts.md",
                    ),
                  ]),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
