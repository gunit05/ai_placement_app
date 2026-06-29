import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire_hub/theme/premium_ui.dart';

class AdminAddJobScreen extends StatefulWidget {
  const AdminAddJobScreen({super.key});

  @override
  State<AdminAddJobScreen> createState() => _AdminAddJobScreenState();
}

class _AdminAddJobScreenState extends State<AdminAddJobScreen> {
  final company = TextEditingController();
  final role = TextEditingController();
  final location = TextEditingController();
  final type = TextEditingController();
  final salary = TextEditingController();
  final description = TextEditingController();

  bool loading = false;

  Future<void> addJob() async {
    if (company.text.isEmpty ||
        role.text.isEmpty ||
        location.text.isEmpty ||
        type.text.isEmpty ||
        salary.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Fill all fields"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await Supabase.instance.client.from('jobs').insert({
        'company': company.text.trim(),
        'role': role.text.trim(),
        'location': location.text.trim(),
        'job_type': type.text.trim(),
        'salary': int.tryParse(salary.text.trim()) ?? 0,
        'description': description.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primary,
          content: const Text("Job posted successfully 🚀"),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: $e"),
        ),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    company.dispose();
    role.dispose();
    location.dispose();
    type.dispose();
    salary.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return PremiumScreen(
      title: "Add Job",
      subtitle: "Create professional job listings",
      icon: Icons.work,
      scrollable: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3B2A5E).withValues(alpha: 0.4)
              : const Color(0xFFEDE7F6).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: PremiumCard(
          child: Column(
            children: [
              GlassIcon(icon: Icons.work),
              const SizedBox(height: 20),
              Text("Post New Job 🚀",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 10),
              Text("Fill out the details below",
                  style: TextStyle(color: secondaryColor)),
              const SizedBox(height: 20),
              _field(company, "Company Name", Icons.business),
              _field(role, "Job Role", Icons.work),
              _field(location, "Location", Icons.location_on),
              _field(type, "Job Type", Icons.category),
              _field(salary, "Salary", Icons.currency_rupee,
                  keyboard: TextInputType.number),
              _field(description, "Description", Icons.description, maxLines: 4),
              const SizedBox(height: 20),
              PremiumButton(
                text: loading ? "Posting..." : "Post Job",
                icon: Icons.send,
                onTap: loading ? () {} : addJob,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: secondaryColor),
          prefixIcon: Icon(icon, color: secondaryColor),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
