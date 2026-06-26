import 'package:mapiafrontend/features/posts/domain/entities/comment_entity.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class MockPostsDatasource {
  const MockPostsDatasource();

  List<PostEntity> getPosts() {
    return [
      PostEntity(
        id: 'food-01',
        title: 'Pollo barato cerca de la plaza',
        description:
            'Están vendiendo pollo a 10 Bs cerca de la plaza. Hay bastante gente, pero la fila avanza rápido y todavía queda buena cantidad.',
        type: PostType.foodDeal,
        authorName: 'Carla Méndez',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160',
        latitude: -16.5117,
        longitude: -68.1243,
        address: 'Sopocachi',
        mediaUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900',
        mediaType: PostMediaType.image,
        likesCount: 24,
        commentsCount: 8,
        isLiked: true,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      PostEntity(
        id: 'event-01',
        title: 'Fiesta universitaria este viernes',
        description:
            'Hay una fiesta universitaria este viernes en Sopocachi. La entrada es económica y anuncian música en vivo desde las 20:00.',
        type: PostType.party,
        authorName: 'Diego Rojas',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160',
        latitude: -16.5089,
        longitude: -68.1264,
        address: 'Sopocachi',
        likesCount: 76,
        commentsCount: 21,
        isLiked: false,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      PostEntity(
        id: 'blockade-01',
        title: 'Bloqueo parcial en la Pérez Velasco',
        description:
            'Hay bloqueo parcial y los minibuses están desviando por calles alternas. El paso está lento hacia el centro.',
        type: PostType.blockade,
        authorName: 'Vecino Mapia',
        latitude: -16.4978,
        longitude: -68.1391,
        address: 'Pérez Velasco',
        likesCount: 41,
        commentsCount: 15,
        isLiked: false,
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      PostEntity(
        id: 'service-01',
        title: 'Corte de agua en Miraflores',
        description:
            'Varias casas reportan corte de agua desde la mañana. Hay baja presión en tres cuadras cercanas a la Av. Saavedra.',
        type: PostType.serviceCut,
        authorName: 'Ana López',
        latitude: -16.5032,
        longitude: -68.1182,
        address: 'Miraflores',
        likesCount: 12,
        commentsCount: 6,
        isLiked: false,
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 34)),
      ),
      PostEntity(
        id: 'sale-01',
        title: 'Venta de salteñas económicas',
        description:
            'Salteñas a buen precio cerca del Prado. Quedan pocas y el puesto está al lado de la parada principal.',
        type: PostType.sale,
        authorName: 'Marco Salazar',
        authorAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160',
        latitude: -16.5007,
        longitude: -68.1329,
        address: 'El Prado',
        mediaUrl:
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=900',
        mediaType: PostMediaType.image,
        likesCount: 19,
        commentsCount: 4,
        isLiked: false,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      PostEntity(
        id: 'traffic-01',
        title: 'Tráfico fuerte por la Av. Busch',
        description:
            'Cola de vehículos hacia Miraflores. Mejor tomar ruta por Saavedra si vas con prisa.',
        type: PostType.traffic,
        authorName: 'Conductor Mapia',
        latitude: -16.5084,
        longitude: -68.1219,
        address: 'Av. Busch',
        likesCount: 33,
        commentsCount: 11,
        isLiked: true,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      PostEntity(
        id: 'accident-01',
        title: 'Accidente leve cerca del Prado',
        description:
            'Choque menor sin heridos. Hay reducción de carril y presencia de tránsito.',
        type: PostType.accident,
        authorName: 'Tránsito ciudadano',
        latitude: -16.5024,
        longitude: -68.1337,
        address: 'El Prado',
        likesCount: 7,
        commentsCount: 3,
        isLiked: false,
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  PostEntity? getPostById(String postId) {
    for (final post in getPosts()) {
      if (post.id == postId) return post;
    }
    return null;
  }

  List<CommentEntity> getCommentsByPostId(String postId) {
    final comments = <String, List<CommentEntity>>{
      'food-01': [
        CommentEntity(
          id: 'c-food-1',
          postId: postId,
          authorName: 'María',
          content: 'Confirmo, todavía hay.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
        ),
        CommentEntity(
          id: 'c-food-2',
          postId: postId,
          authorName: 'Diego',
          content: 'Exactamente por dónde?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        CommentEntity(
          id: 'c-food-3',
          postId: postId,
          authorName: 'Ana',
          content: 'Ya se está acabando, pero atienden rápido.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
      'blockade-01': [
        CommentEntity(
          id: 'c-blockade-1',
          postId: postId,
          authorName: 'Luis',
          content: 'Los minibuses están entrando por la Buenos Aires.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        CommentEntity(
          id: 'c-blockade-2',
          postId: postId,
          authorName: 'Sofía',
          content: 'Sigue lento hacia San Francisco.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ],
      'service-01': [
        CommentEntity(
          id: 'c-service-1',
          postId: postId,
          authorName: 'Paola',
          content: 'En mi cuadra también se cortó desde temprano.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
      ],
    };

    return comments[postId] ??
        [
          CommentEntity(
            id: 'c-default-1',
            postId: postId,
            authorName: 'Vecina Mapia',
            content: 'Gracias por el dato, ayuda bastante.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
          ),
          CommentEntity(
            id: 'c-default-2',
            postId: postId,
            authorName: 'Carlos',
            content: 'Alguien puede confirmar si sigue igual?',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ];
  }
}
