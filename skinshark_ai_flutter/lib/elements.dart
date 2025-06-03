import 'package:skinshark_ai_fixed/utils/imports.dart';
import 'package:intl/intl.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late Future<List<HistoryEntry>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final userId = Auth().currentUser?.uid ?? "";
    _futureHistory = StorageUtil.getHistoryEntries(userId);
  }

  Future<void> _removeEntry(HistoryEntry entry) async {
    final currentUserId = Auth().currentUser?.uid ?? "";
    if (entry.userId == currentUserId) {
      await StorageUtil.removeElement(currentUserId, entry.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Element removed.")));
      setState(() => _loadHistory()); // Reload list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only remove your own history.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryEntry>>(
      future: _futureHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No history found."));
        }

        final history = snapshot.data!;
        return Container(
          color: Colors.grey[100],
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[history.length - 1 - index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(entry.image),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 48),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text("Disease: ${entry.diseaseName}"),
                      Text(
                        "Confidence: ${(entry.confidence * 100).toStringAsFixed(2)}%",
                      ),
                      Text("Recommendations: ${entry.recommendations}"),
                      Text(
                        "Date: ${DateFormat.yMMMd().add_jm().format(entry.date)}",
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _removeEntry(entry),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Remove"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FeatureIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const FeatureIcon({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class OptionCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const OptionCard({Key? key, required this.label, required this.icon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add what happens when the card is clicked here
        print("$label clicked!");
        // Navigate to a new screen if needed
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SomeScreen()));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 120,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EducationSection extends StatelessWidget {
  const EducationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // отступы от краёв
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // выравнивание влево
        children: [
          const SizedBox(height: 24),
          const Text(
            "Education: Common conditions",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Learn about common skin conditions and how to treat them.\n"
            "This section provides articles and resources to help you understand your skin better.\n",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ArticleCard(
                  title: "Guide to Skin Cancer",
                  imageUrl:
                      "https://miiskin.com/wp-content/uploads/2019/08/types-of-skin-cancer.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationScreen(),
                      ),
                    );
                  },
                ),
                ArticleCard(
                  title: "How to Prevent Acne",
                  imageUrl:
                      "https://thenakedchemist.com/wp-content/uploads/2022/07/20_YWNuZQ-1024x932.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationScreen(),
                      ),
                    );
                  },
                ),
                ArticleCard(
                  title: "Best Skincare Routines",
                  imageUrl:
                      "https://hips.hearstapps.com/hmg-prod/images/skincare-steps-677e840842f99.jpg?crop=1.00xw:0.750xh;0,0.0944xh&resize=1200:*",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationScreen(),
                      ),
                    );
                  },
                ),
                ArticleCard(
                  title: "Understanding Eczema",
                  imageUrl:
                      "https://www.eczemaexposed.com/-/media/ems/conditions/dermatology/brands/dupi-unbranded/eczema/understanding-eczema/eczema-example-2.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const HistoryList(),
        ],
      ),
    );
  }
}

class TryAgainButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TryAgainButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text("Try Again"),
      ),
    );
  }
}

class SkinConditionResults extends StatelessWidget {
  final String diseaseName;
  final double confidence;
  final String recommendations;

  const SkinConditionResults({
    required this.diseaseName,
    required this.confidence,
    required this.recommendations,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Skin Conditions Detected:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Condition: $diseaseName",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CardContainer(
          child: ExpansionTile(
            leading: const Icon(Icons.medical_services, color: primaryColor),
            title: const Text(
              "Treatment and Preventive Plan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              const SizedBox(height: 8),
              Text(recommendations, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class PhotoCard extends StatelessWidget {
  final File? imageFile;
  final bool imageUploaded;
  final VoidCallback onPressed;

  const PhotoCard({
    required this.imageFile,
    required this.imageUploaded,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                imageFile != null
                    ? Image.file(imageFile!, height: 240, fit: BoxFit.cover)
                    : Image.asset('assets/images/skinfront.jpg', height: 240),
          ),
          const SizedBox(height: 12),
          const Text(
            "Analyze your skin now!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(
              imageUploaded ? "Photo Uploaded" : "Snap a photo or upload one",
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;

  const CardContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
