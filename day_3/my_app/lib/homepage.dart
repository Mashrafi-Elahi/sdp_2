import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
  int selectedstate=0;
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        // title kept as "Roll Dice"
        title: const Text('Roll Dice'),
        centerTitle: true,
        // Removed custom leading icon to ensure the 3-line drawer button works
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Image.network(
                'https://cf.bstatic.com/xdata/images/hotel/max1024x768/12345678.jpg', // Keeping the image
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      // Body content with original buttons
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('1 Player'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('2 Player'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index){
          setState(() {
            selectedState=Index;
          });
        }
        currentIndex: selectedState ,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),BottomNavigationBarItem(icon: Icon(Icons.search),
          label: 'Search'),
        ],
      ),
    );
  }
}
