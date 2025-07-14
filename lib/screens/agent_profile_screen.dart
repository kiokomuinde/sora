// lib/screens/agent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class AgentProfileScreen extends StatefulWidget {
  final AuthService authService;
  // This screen might take an agent ID or data to display a specific agent's profile
  final Map<String, dynamic>? agentData;

  const AgentProfileScreen({super.key, required this.authService, this.agentData});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  late CommonWidgets commonWidgets;

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    String agentName = widget.agentData?['name'] ?? 'Agent Name Not Provided';
    String agentEmail = widget.agentData?['email'] ?? 'N/A';
    String agentPhone = widget.agentData?['phone'] ?? 'N/A';
    String agentImage = widget.agentData?['image'] ?? 'assets/images/default_agent.jpeg'; // Provide a default image
    String agentBio = widget.agentData?['bio'] ?? 'No biography available for this agent.';
    List<dynamic> agentSpecialties = widget.agentData?['specialties'] ?? [];

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 60 : (isMediumScreen ? 40 : 30),
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).colorScheme.secondary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agentName,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 48 : (isMediumScreen ? 36 : 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Real Estate Agent',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: isLargeScreen ? 80 : (isMediumScreen ? 60 : 50),
                      backgroundImage: AssetImage(agentImage),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      agentName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Email: $agentEmail',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Phone: $agentPhone',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'About Me',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    agentBio,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  if (agentSpecialties.isNotEmpty) ...[
                    const Text(
                      'Specialties',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: agentSpecialties.map((specialty) => Chip(
                            label: Text(specialty),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                          )).toList(),
                    ),
                  ],
                  const SizedBox(height: 30),
                  // You might add a list of properties by this agent here
                  // Or a contact form
                ],
              ),
            ),
            commonWidgets.buildFooter(),
          ],
        ),
      ),
    );
  }
}