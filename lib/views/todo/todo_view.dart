import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/todo/todo_view_model.dart';
import '../../models/todo.dart';
import '../../core/theme/app_colors.dart';

/// TODO视图（待办事项）
class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> with SingleTickerProviderStateMixin {
  late TodoViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = TodoViewModel();
    _viewModel.initialize();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              // 标题和操作栏
              _buildHeader(),
              
              // Tab栏
              _buildTabBar(),
              
              // 内容区域
              Expanded(
                child: Consumer<TodoViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // 未完成
                        _buildIncompleteList(viewModel),
                        // 已完成
                        _buildCompletedList(viewModel),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  /// 头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '待办事项',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<TodoViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<TodoFilter>(
                icon: const Icon(Icons.filter_list),
                onSelected: (filter) => viewModel.setFilter(filter),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TodoFilter.all,
                    child: Row(
                      children: [
                        Icon(
                          Icons.all_inclusive,
                          color: viewModel.currentFilter == TodoFilter.all
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('全部'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TodoFilter.today,
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: viewModel.currentFilter == TodoFilter.today
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('今天到期'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TodoFilter.overdue,
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: viewModel.currentFilter == TodoFilter.overdue
                              ? Colors.red
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('已逾期'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TodoFilter.highPriority,
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: viewModel.currentFilter == TodoFilter.highPriority
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('高优先级'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Consumer<TodoViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<TodoSortBy>(
                icon: const Icon(Icons.sort),
                onSelected: (sort) => viewModel.setSort(sort),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TodoSortBy.priority,
                    child: Row(
                      children: [
                        Icon(
                          Icons.low_priority,
                          color: viewModel.currentSort == TodoSortBy.priority
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('按优先级'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TodoSortBy.dueDate,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: viewModel.currentSort == TodoSortBy.dueDate
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('按到期日期'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TodoSortBy.createdDate,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: viewModel.currentSort == TodoSortBy.createdDate
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        const Text('按创建日期'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Tab栏
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          return TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                text: '未完成 (${viewModel.incompleteCount})',
              ),
              Tab(
                text: '已完成 (${viewModel.completedCount})',
              ),
            ],
          );
        },
      ),
    );
  }

  /// 未完成列表
  Widget _buildIncompleteList(TodoViewModel viewModel) {
    final todos = viewModel.filteredIncompleteTodos;

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无待办事项',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角 + 按钮添加',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadTodos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return _buildTodoCard(todo, viewModel);
        },
      ),
    );
  }

  /// 已完成列表
  Widget _buildCompletedList(TodoViewModel viewModel) {
    final todos = viewModel.completedTodos;

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无已完成的待办事项',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 清空按钮
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showClearCompletedDialog(viewModel),
            icon: const Icon(Icons.delete_sweep),
            label: const Text('清空已完成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              elevation: 0,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.loadTodos(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _buildTodoCard(todo, viewModel);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 待办事项卡片
  Widget _buildTodoCard(Todo todo, TodoViewModel viewModel) {
    return Dismissible(
      key: Key('todo_${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        viewModel.deleteTodo(todo.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: todo.completed,
            onChanged: (_) => viewModel.toggleComplete(todo),
            activeColor: AppColors.checkIn,
            shape: const CircleBorder(),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              color: todo.completed ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  todo.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    decoration: todo.completed ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  // 优先级标签
                  _buildPriorityChip(todo.priority),
                  const SizedBox(width: 8),
                  // 到期日期
                  if (todo.dueDate != null) _buildDueDateChip(todo),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showEditTodoDialog(todo),
          ),
        ),
      ),
    );
  }

  /// 优先级标签
  Widget _buildPriorityChip(int priority) {
    String label;
    Color color;
    switch (priority) {
      case 3:
        label = '高';
        color = Colors.red;
        break;
      case 2:
        label = '中';
        color = Colors.orange;
        break;
      default:
        label = '低';
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 到期日期标签
  Widget _buildDueDateChip(Todo todo) {
    Color color = Colors.grey;
    IconData icon = Icons.calendar_today;

    if (todo.isOverdue) {
      color = Colors.red;
      icon = Icons.warning;
    } else if (todo.isDueToday) {
      color = Colors.orange;
      icon = Icons.today;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          _formatDueDate(todo.dueDate!),
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 格式化到期日期
  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate == today) {
      return '今天';
    } else if (dueDate == today.add(const Duration(days: 1))) {
      return '明天';
    } else if (dueDate == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  /// 显示添加待办对话框
  Future<void> _showAddTodoDialog() async {
    await _showTodoDialog(
      title: '添加待办',
      onSave: (title, description, dueDate, priority) async {
        final success = await _viewModel.addTodo(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '添加成功' : '添加失败'),
              backgroundColor: success ? AppColors.checkIn : Colors.red,
            ),
          );
        }
      },
    );
  }

  /// 显示编辑待办对话框
  Future<void> _showEditTodoDialog(Todo todo) async {
    await _showTodoDialog(
      title: '编辑待办',
      initialTitle: todo.title,
      initialDescription: todo.description,
      initialDueDate: todo.dueDate,
      initialPriority: todo.priority,
      onSave: (title, description, dueDate, priority) async {
        final updatedTodo = todo.copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );

        final success = await _viewModel.updateTodo(updatedTodo);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '更新成功' : '更新失败'),
              backgroundColor: success ? AppColors.checkIn : Colors.red,
            ),
          );
        }
      },
    );
  }

  /// 显示待办对话框
  Future<void> _showTodoDialog({
    required String title,
    String? initialTitle,
    String? initialDescription,
    DateTime? initialDueDate,
    int initialPriority = 2,
    required Future<void> Function(String title, String? description, DateTime? dueDate, int priority) onSave,
  }) async {
    final titleController = TextEditingController(text: initialTitle);
    final descriptionController = TextEditingController(text: initialDescription);
    DateTime? selectedDueDate = initialDueDate;
    int selectedPriority = initialPriority;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '输入待办事项标题',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                // 描述
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    hintText: '输入详细描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                // 到期日期
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('到期日期'),
                  subtitle: Text(
                    selectedDueDate != null
                        ? '${selectedDueDate!.year}-${selectedDueDate!.month.toString().padLeft(2, '0')}-${selectedDueDate!.day.toString().padLeft(2, '0')}'
                        : '未设置',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedDueDate = null;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDueDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 优先级
                const Text('优先级', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('低'), icon: Icon(Icons.low_priority)),
                    ButtonSegment(value: 2, label: Text('中'), icon: Icon(Icons.remove)),
                    ButtonSegment(value: 3, label: Text('高'), icon: Icon(Icons.priority_high)),
                  ],
                  selected: {selectedPriority},
                  onSelectionChanged: (Set<int> selected) {
                    setState(() {
                      selectedPriority = selected.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final todoTitle = titleController.text.trim();
                if (todoTitle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入标题')),
                  );
                  return;
                }

                final description = descriptionController.text.trim();
                onSave(
                  todoTitle,
                  description.isEmpty ? null : description,
                  selectedDueDate,
                  selectedPriority,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示清空已完成对话框
  Future<void> _showClearCompletedDialog(TodoViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: Text('确定要清空所有已完成的待办事项吗？\n共 ${viewModel.completedCount} 项'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final success = await viewModel.clearCompleted();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '已清空' : '清空失败'),
            backgroundColor: success ? AppColors.checkIn : Colors.red,
          ),
        );
      }
    }
  }
}
