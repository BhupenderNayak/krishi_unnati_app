import 'package:flutter/material.dart';
import 'package:krishi_01/screens/create_post_screen.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  final List<Map<String, String>> dummyPosts = const [
    {
      'authorName': 'Ramesh Kumar',
      'time': '5 mins ago',
      'content': 'Dosto, iss saal gehu ki fasal kaisi rahi? Meri toh bahut achhi hui hai!',
    },
    {
      'authorName': 'Priya Devi',
      'time': '1 hour ago',
      'content': 'Kya koi mujhe bata sakta hai ki organic khaad kaise banate hain? Naye tareeke seekhna chahti hoon.',
    },
    {
      'authorName': 'Sandeep Singh',
      'time': '3 hours ago',
      'content': 'Pyaz ke daam mandi mein kaise chal rahe hain? Kisne becha hai abhi tak?',
    },
    {
      'authorName': 'Anjali Sharma',
      'time': '1 day ago',
      'content': 'Sarkar ki nayi scheme "Kisan Samman Nidhi" ke baare mein kaun-kaun jaanta hai? Iske kya fayde hain?',
    },
    {
      'authorName': 'Vikas Patel',
      'time': '2 days ago',
      'content': 'Naye seed varieties try kiye hain kisi ne? Main Dhan ki nayi kism lagana chahta hoon.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: dummyPosts.length,
        itemBuilder: (context, index) {
          final post = dummyPosts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.person_outline, color: Colors.green),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['authorName']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            post['time']!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post['content']!,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.thumb_up_alt_outlined, 'Like'),
                      _buildActionButton(Icons.comment_outlined, 'Comment'),
                      _buildActionButton(Icons.share_outlined, 'Share'),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create Post',
      ),
    );
  }


  Widget _buildActionButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {
      },
      icon: Icon(icon, size: 20, color: Colors.grey[700]),
      label: Text(label, style: TextStyle(color: Colors.grey[800])),
    );
  }
}