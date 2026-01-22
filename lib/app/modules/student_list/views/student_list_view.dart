import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/student_list_controller.dart';

class StudentListView extends GetView<StudentListController> {
  const StudentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD),
      appBar: AppBar(
        title: const Text("Daftar Siswa", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      // TOMBOL TAMBAH (+) MENGAMBANG
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(context),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text("Siswa Baru"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.studentsStream,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State (Kalau belum ada data)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Belum ada siswa", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          // 3. List Data Siswa
          var documents = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              String docId = documents[index].id;

              return _buildStudentCard(data, docId);
            },
          );
        },
      ),
    );
  }

  // WIDGET KARTU SISWA
  Widget _buildStudentCard(Map<String, dynamic> data, String docId) {
    bool isLaki = data['jenis_kelamin'] == 'L';
    
    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteStudent(docId),
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          leading: CircleAvatar(
            backgroundColor: isLaki ? Colors.blue.shade50 : Colors.pink.shade50,
            radius: 25,
            child: Icon(
              isLaki ? Icons.face : Icons.face_3, 
              color: isLaki ? Colors.blue : Colors.pink
            ),
          ),
          title: Text(
            data['nama_siswa'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text("Kelas: ${data['kelas'] ?? '-'}"),
          trailing: ElevatedButton(
            onPressed: () => controller.goToAssessment(data, docId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Nilai"),
          ),
        ),
      ),
    );
  }

  // DIALOG FORM TAMBAH SISWA
  void _showAddStudentDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: Text("Tambah Siswa Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              
              TextField(
                controller: controller.namaC,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: controller.kelasC,
                decoration: InputDecoration(
                  labelText: "Kelas (Contoh: TK-A)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),

              // Pilihan Gender (Radio Button Custom)
              const Text("Jenis Kelamin:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  _genderOption("Laki-laki", 'L', Colors.blue),
                  const SizedBox(width: 15),
                  _genderOption("Perempuan", 'P', Colors.pink),
                ],
              )),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.addStudent(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Biar gak ketutup keyboard
    );
  }

  Widget _genderOption(String label, String value, Color color) {
    bool isSelected = controller.selectedGender.value == value;
    return GestureDetector(
      onTap: () => controller.selectedGender.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}