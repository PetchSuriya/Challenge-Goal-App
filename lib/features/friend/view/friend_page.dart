import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

/// Friend model class
class Friend {
  final String id;
  final String name;
  final String status;
  final int goals;

  Friend({
    required this.id,
    required this.name,
    required this.status,
    required this.goals,
  });
}

/// FriendPage - Page for managing friends and social features
class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  // Friends list state
  late List<Friend> _friends;
  late List<Friend> _incomingRequests;

  @override
  void initState() {
    super.initState();
    _initializeFriends();
    _initializeIncomingRequests();
  }

  void _initializeFriends() {
    _friends = List.generate(
      6,
      (i) => Friend(
        id: 'friend_${i + 1}',
        name: 'Friend ${i + 1}',
        status: i % 3 == 0
            ? 'Active'
            : i % 3 == 1
            ? 'Away'
            : 'Offline',
        goals: (i + 1) * 2,
      ),
    );
  }

  void _initializeIncomingRequests() {
    // Sample incoming requests - replace with API data as needed
    _incomingRequests = [
      Friend(id: 'req_1', name: 'Sam Carter', status: 'Offline', goals: 2),
      Friend(id: 'req_2', name: 'Priya Singh', status: 'Offline', goals: 1),
    ];
  }

  void _showIncomingRequests() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (c, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.purple.shade100]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('People who added you', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
                if (_incomingRequests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${_incomingRequests.length} requests', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _incomingRequests.isEmpty
                  ? Text('No incoming friend requests', style: TextStyle(color: Colors.black87))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final req = _incomingRequests[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade100,
                              child: Text(req.name[0], style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(req.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                            subtitle: Text('${req.goals} goals', style: TextStyle(color: Colors.black54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Accept: add to friends
                                    setState(() {
                                      _friends.add(req);
                                      _incomingRequests.removeWhere((r) => r.id == req.id);
                                    });
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Accepted ${req.name}')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    // Decline
                                    setState(() {
                                      _incomingRequests.removeWhere((r) => r.id == req.id);
                                    });
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Declined ${req.name}')),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade600,
                                    side: BorderSide(color: Colors.red.shade100),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemCount: _incomingRequests.length,
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
                style: TextButton.styleFrom(foregroundColor: Colors.black87),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteFriend(String friendId) {
    setState(() {
      _friends.removeWhere((friend) => friend.id == friendId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend removed successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation(String friendName, String friendId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Friend'),
          content: Text(
            'Are you sure you want to remove $friendName from your friends list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFriend(friendId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _onAddFriend() {
    final rootCtx = context;
    final TextEditingController _searchCtrl = TextEditingController();
    List<Friend> results = [];

    showDialog(
      context: rootCtx,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            void doSearch() {
              final q = _searchCtrl.text.trim().toLowerCase();
              setState(() {
                if (q.isEmpty) {
                  results = [];
                } else {
                  results = _friends.where((f) => f.name.toLowerCase().contains(q)).toList();
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text(
                'Find a friend',
                // Dialog title remains semibold but color applied below for clarity
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Type a friend name',
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.blue.shade600),
                        onPressed: doSearch,
                      ),
                    ),
                    onSubmitted: (_) => doSearch(),
                  ),
                  const SizedBox(height: 12),
                  if (results.isEmpty)
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('No results', style: TextStyle(color: Colors.black87)),
                    )
                  else
                    SizedBox(
                      height: 220,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (c, i) {
                          final f = results[i];
                          return Card(
                            color: Colors.blue.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                child: Text(
                                  f.name[0],
                                  style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                f.name,
                                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${f.goals} goals',
                                style: TextStyle(color: Colors.blueGrey.shade700),
                              ),
                              onTap: () {
                                Navigator.of(dialogCtx).pop();
                                ScaffoldMessenger.of(rootCtx).showSnackBar(
                                  SnackBar(content: Text('Selected ${f.name}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                  style: TextButton.styleFrom(foregroundColor: Colors.black87),
                ),
                TextButton(
                  onPressed: () {
                    // Close this dialog then show incoming requests
                    Navigator.of(dialogCtx).pop();
                    _showIncomingRequests();
                  },
                  child: const Text('Requests'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
                ),
                TextButton(
                  onPressed: () {
                    doSearch();
                  },
                  child: const Text('Search'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                ),
              ],
            );
          },
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.dashboardRoute),
          color: Colors.black87,
        ),
        // Search removed; Add Friend moved into the Friends Overview card
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Friends Summary Card (Add Friend button moved here)
            _FriendsSummaryCard(
              totalFriends: _friends.length,
              activeFriends: _friends.where((f) => f.status == 'Active').length,
              mutualGoals: _friends.fold(0, (sum, f) => sum + f.goals),
              onAdd: _onAddFriend,
            ),

            const SizedBox(height: 16),

            // Header: Your Friends
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Friends',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Show all friends
                  },
                  icon: const Icon(Icons.people_outline),
                  label: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Friends List
            _buildFriendsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some friends to get started!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return GestureDetector(
          onTap: () {
            // Navigate to friend's profile page
            context.go(
              '/friends/${friend.name}?avatarUrl=assets/images/avatar.png',
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    friend.name[0],
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${friend.goals} goals',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showDeleteConfirmation(friend.name, friend.id),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      tooltip: 'Delete friend',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FriendsSummaryCard extends StatelessWidget {
  final int totalFriends;
  final int activeFriends;
  final int mutualGoals;
  final VoidCallback? onAdd;

  const _FriendsSummaryCard({
    required this.totalFriends,
    required this.activeFriends,
    required this.mutualGoals,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Friends Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              if (onAdd != null) ...[
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: const Text('Add Friend'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Friends',
                  value: totalFriends.toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Active Now',
                  value: activeFriends.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Mutual Goals',
                  value: mutualGoals.toString(),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

