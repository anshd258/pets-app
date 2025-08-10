import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/pet_list/pet_list_bloc.dart';

class NetworkIndicator extends StatelessWidget {
  const NetworkIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        if (state is! PetListLoaded) return const SizedBox.shrink();
        
        if (state.isOnline) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color: Colors.orange.shade800,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.lastSyncTime != null)
                      Text(
                        'Last updated: ${_formatLastSync(state.lastSyncTime!)}',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<PetListBloc>().add(RefreshPets());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatLastSync(DateTime lastSync) {
    final difference = DateTime.now().difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}