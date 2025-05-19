// /lib/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("SORA"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, User!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Find your dream home today.", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),

          SizedBox(height: 20),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search property...",
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),

          SizedBox(height: 20),

          // Quick Actions Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickAction(context, "Browse Properties", Icons.home_work, '/property_listings'),
              _buildQuickAction(context, "Favorites", Icons.favorite_outline, '/favorites'),
              _buildQuickAction(context, "Advanced Search", Icons.tune, '/search'),
              _buildQuickAction(context, "Contact Agent", Icons.chat_bubble_outline, '/chat'),
            ],
          ),

          SizedBox(height: 30),

          // Featured Properties
          Text("Featured Listings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          "https://picsum.photos/seed/$index/400/300",
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.6),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Muthaiga Mansion", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text("KSH 120,000,000", style: TextStyle(color: Colors.yellowAccent)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 30),

          // // Call-to-Action Button
          // ElevatedButton.icon(
          //   onPressed: () {},
          //   icon: Icon(Icons.add),
          //   label: Text("Post Your Property"),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Color(0xFF1E90FF),
          //     padding: EdgeInsets.symmetric(vertical: 16),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () {
        if (route == '/property_listings') {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2 - 8,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF1E90FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFF1E90FF)),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}