import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/pet_model.dart';
import '../../logic/blocs/pet_details/pet_details_bloc.dart';
import '../../logic/blocs/pet_list/pet_list_bloc.dart';
import '../../logic/blocs/favorites/favorites_bloc.dart';
import '../../logic/blocs/history/history_bloc.dart';

class DetailsPage extends StatefulWidget {
  final PetModel pet;

  const DetailsPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    context.read<PetDetailsBloc>().add(LoadPetDetails(pet: widget.pet));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showZoomableImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context, String petName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 Congratulations!'),
          content: Text("You've now adopted $petName!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confettiController.play();
              },
              child: const Text('Celebrate!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<PetDetailsBloc, PetDetailsState>(
      listener: (context, state) {
        if (state is PetDetailsLoaded) {
          if (state.adoptionMessage != null) {
            _showAdoptionDialog(context, state.pet.name);
            context.read<PetListBloc>().add(UpdatePetInList(pet: state.pet));
            context.read<HistoryBloc>().add(LoadHistory());
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            BlocBuilder<PetDetailsBloc, PetDetailsState>(
              builder: (context, state) {
                if (state is! PetDetailsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pet = state.pet;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: size.height * 0.4,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: GestureDetector(
                          onTap: () => _showZoomableImage(context, pet.imageUrl),
                          child: Hero(
                            tag: 'pet_${pet.id}',
                            child: CachedNetworkImage(
                              imageUrl: pet.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.pets,
                                  size: 100,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            pet.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: pet.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            context.read<PetDetailsBloc>().add(ToggleFavorite());
                            context.read<FavoritesBloc>().add(LoadFavorites());
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pet.name,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (pet.isAdopted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Adopted',
                                        style: TextStyle(
                                          color: theme.colorScheme.onError,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pet.breed,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.cake,
                                    label: '${pet.age} years',
                                  ),
                                  const SizedBox(width: 12),
                                  _InfoChip(
                                    icon: Icons.attach_money,
                                    label: '${pet.price.toStringAsFixed(0)}',
                                  ),
                                  if (pet.gender != null) ...[
                                    const SizedBox(width: 12),
                                    _InfoChip(
                                      icon: pet.gender!.toLowerCase() == 'male'
                                          ? Icons.male
                                          : Icons.female,
                                      label: pet.gender!,
                                      iconColor: pet.gender!.toLowerCase() == 'male'
                                          ? Colors.blue
                                          : Colors.pink,
                                    ),
                                  ],
                                  if (pet.size != null) ...[
                                    const SizedBox(width: 12),
                                    _InfoChip(
                                      icon: Icons.straighten,
                                      label: pet.size!,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'About ${pet.name}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pet.description,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              if (pet.adoptedAt != null) ...[
                                Card(
                                  color: theme.colorScheme.primaryContainer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Adoption Date',
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  color: theme.colorScheme.onPrimaryContainer,
                                                ),
                                              ),
                                              Text(
                                                '${pet.adoptedAt!.day}/${pet.adoptedAt!.month}/${pet.adoptedAt!.year}',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 80),
                              ] else
                                const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<PetDetailsBloc, PetDetailsState>(
              builder: (context, state) {
                if (state is! PetDetailsLoaded || state.pet.isAdopted) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<PetDetailsBloc>().add(AdoptPet());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Adopt Me',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: (size) {
                  final path = Path();
                  path.addOval(Rect.fromCircle(center: Offset.zero, radius: 4));
                  return path;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _InfoChip({
    Key? key,
    required this.icon,
    required this.label,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}