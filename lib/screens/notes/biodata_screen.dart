import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiodataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Saya',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/image/profile.jpg'),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Ahmad Mufarizal Hammi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black26,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Mahasiswa Semester 3',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Info Sections
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    'Tentang Saya',
                    'Saya adalah pengembang aplikasi Flutter yang sedang belajar dan mengembangkan kemampuan di bidang teknologi. Saat ini fokus pada pengembangan aplikasi mobile dan web menggunakan Flutter framework.',
                    Icons.person,
                  ),
                  _buildInfoSection(
                    'Pendidikan',
                    'Politeknik Takumi\nProgram Studi Teknologi Informasi\nTahun 2023 - Sekarang',
                    Icons.school,
                  ),
                  _buildInfoSection(
                    'Keahlian',
                    '•Mobile App Development\n• UI/UX Design\n• Git Version Control',
                    Icons.code,
                  ),
                  _buildInfoSection(
                    'Kontak',
                    'Email: ahmadmufaridzal@gmail.com\nTelepon: +62 89529818284\nAlamat: Jl.in aja dulu',
                    Icons.contact_mail,
                  ),
                  _buildInfoSection(
                    'My Project',
                    '',
                    Icons.perm_media,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
