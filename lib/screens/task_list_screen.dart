import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  String _searchQuery = '';
  bool _sortByTime = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskStorage.loadTasks();
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _saveTasks() async {
    await TaskStorage.saveTasks(_tasks);
  }

  List<Task> get _filteredTasks {
    List<Task> result = _tasks.where((t) =>
    t.tenCongViec.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.diaDiem.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    if (_sortByTime) {
      result.sort((a, b) {
        if (a.thoiGian == null && b.thoiGian == null) return 0;
        if (a.thoiGian == null) return 1;
        if (b.thoiGian == null) return -1;
        return a.thoiGian!.compareTo(b.thoiGian!);
      });
    }
    return result;
  }

  void _goToAddTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (result != null) {
      setState(() => _tasks.add(result));
      await _saveTasks();
    }
  }

  void _editTask(int index) async {
    final actualIndex = _tasks.indexOf(_filteredTasks[index]);
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(existingTask: _tasks[actualIndex]),
      ),
    );
    if (result != null) {
      setState(() => _tasks[actualIndex] = result);
      await _saveTasks();
    }
  }

  void _deleteTask(int index) async {
    final actualIndex = _tasks.indexOf(_filteredTasks[index]);
    final task = _tasks[actualIndex];
    setState(() => _tasks.removeAt(actualIndex));
    await _saveTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa: ${task.tenCongViec}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              setState(() => _tasks.insert(actualIndex, task));
              await _saveTasks();
            },
          ),
        ),
      );
    }
  }

  void _toggleHoanThanh(int index) async {
    final actualIndex = _tasks.indexOf(_filteredTasks[index]);
    setState(() => _tasks[actualIndex].hoanThanh = !_tasks[actualIndex].hoanThanh);
    await _saveTasks();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Chưa đặt';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  IconData _nhacIcon(NotificationType t) {
    switch (t) {
      case NotificationType.bell: return Icons.notifications;
      case NotificationType.email: return Icons.email;
      case NotificationType.notification: return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Nhắc Việc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_sortByTime ? Icons.access_time_filled : Icons.access_time),
            tooltip: 'Sắp xếp theo thời gian',
            onPressed: () => setState(() => _sortByTime = !_sortByTime),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        tooltip: 'Thêm công việc',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm công việc...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Chưa có công việc nào' : 'Không tìm thấy kết quả',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) => _buildTaskCard(_filteredTasks[index], index),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    final isPast = task.thoiGian != null &&
        task.thoiGian!.isBefore(DateTime.now()) &&
        !task.hoanThanh;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.hoanThanh ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isPast ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: task.hoanThanh,
              activeColor: const Color(0xFF4A90E2),
              onChanged: (_) => _toggleHoanThanh(index),
            ),
          ],
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: task.priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                task.tenCongViec,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: task.hoanThanh ? TextDecoration.lineThrough : null,
                  color: task.hoanThanh ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: isPast ? Colors.red : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(task.thoiGian),
                  style: TextStyle(fontSize: 12, color: isPast ? Colors.red : Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: task.priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priorityText,
                    style: TextStyle(fontSize: 11, color: task.priorityColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (task.diaDiem.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.diaDiem,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (task.nhacViec) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(_nhacIcon(task.loaiNhac), size: 13, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(task.loaiNhacText, style: const TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') _editTask(index);
            if (value == 'delete') _deleteTask(index);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(
              children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Chỉnh sửa')],
            )),
            const PopupMenuItem(value: 'delete', child: Row(
              children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))],
            )),
          ],
        ),
        onTap: () => _editTask(index),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nhắc Việc'),
        content: const Text(
          'Ứng dụng giúp bạn quản lý công việc hàng ngày.\n\n'
              '• Thêm công việc với tên, thời gian, địa điểm\n'
              '• Đặt mức ưu tiên: Cao / Trung bình / Thấp\n'
              '• Đánh dấu hoàn thành bằng checkbox\n'
              '• Tìm kiếm công việc\n'
              '• Sắp xếp theo thời gian\n',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}