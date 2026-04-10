import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _diaDiemController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _nhacViec = false;
  NotificationType _loaiNhac = NotificationType.bell;
  bool _showLoaiNhac = false;
  Priority _priority = Priority.trung;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _tenController.text = task.tenCongViec;
      _diaDiemController.text = task.diaDiem;
      _selectedDateTime = task.thoiGian;
      _nhacViec = task.nhacViec;
      _loaiNhac = task.loaiNhac;
      _showLoaiNhac = task.nhacViec;
      _priority = task.priority;
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _diaDiemController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final task = Task(
      id: widget.existingTask?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      tenCongViec: _tenController.text.trim(),
      thoiGian: _selectedDateTime,
      diaDiem: _diaDiemController.text.trim(),
      nhacViec: _nhacViec,
      loaiNhac: _loaiNhac,
      priority: _priority,
      hoanThanh: widget.existingTask?.hoanThanh ?? false,
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Chỉnh sửa công việc' : 'Thêm công việc',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(children: [
                _buildLabel('Tên công việc', Icons.title),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tenController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên công việc...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tên công việc'
                      : null,
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard(children: [
                _buildLabel('Thời gian', Icons.access_time),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDateTime != null
                              ? DateFormat('dd/MM/yyyy  HH:mm')
                              .format(_selectedDateTime!)
                              : 'Chọn ngày và giờ',
                          style: TextStyle(
                            color: _selectedDateTime != null
                                ? Colors.black87
                                : Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDateTime != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDateTime = null),
                            child: Icon(Icons.close,
                                size: 18, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard(children: [
                _buildLabel('Địa điểm', Icons.location_on),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _diaDiemController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: true,
                  decoration: const InputDecoration(
                    hintText: 'Nhập địa điểm (tùy chọn)...',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard(children: [
                _buildLabel('Mức ưu tiên', Icons.flag),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPriorityBtn(
                        Priority.cao, 'Cao', const Color(0xFFE53935)),
                    const SizedBox(width: 8),
                    _buildPriorityBtn(Priority.trung, 'Trung bình',
                        const Color(0xFFFB8C00)),
                    const SizedBox(width: 8),
                    _buildPriorityBtn(
                        Priority.thap, 'Thấp', const Color(0xFF43A047)),
                  ],
                ),
              ]),
              const SizedBox(height: 16),
              _buildCard(children: [
                Row(
                  children: [
                    _buildLabel('Nhắc việc trước 1 ngày', Icons.notifications),
                    const Spacer(),
                    Switch(
                      value: _nhacViec,
                      activeColor: const Color(0xFF4A90E2),
                      onChanged: (val) => setState(() {
                        _nhacViec = val;
                        _showLoaiNhac = val;
                      }),
                    ),
                  ],
                ),
                if (_showLoaiNhac) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildNhacOption(NotificationType.bell, 'Nhắc bằng chuông',
                      Icons.notifications),
                  _buildNhacOption(
                      NotificationType.email, 'Nhắc bằng email', Icons.email),
                  _buildNhacOption(NotificationType.notification,
                      'Nhắc bằng thông báo', Icons.message),
                ],
              ]),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  isEdit ? 'Cập nhật công việc' : 'Ghi lại công việc',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBtn(Priority p, String label, Color color) {
    final selected = _priority == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = p),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? color : Colors.grey.shade300,
                width: selected ? 2 : 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : Colors.grey[600],
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A90E2)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF333333))),
      ],
    );
  }

  Widget _buildNhacOption(
      NotificationType type, String label, IconData icon) {
    final selected = _loaiNhac == type;
    return GestureDetector(
      onTap: () => setState(() => _loaiNhac = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8F0FD)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? const Color(0xFF4A90E2)
                  : Colors.grey.shade300,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? const Color(0xFF4A90E2)
                    : Colors.grey),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? const Color(0xFF4A90E2)
                        : Colors.grey[700],
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal)),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF4A90E2), size: 20),
          ],
        ),
      ),
    );
  }
}