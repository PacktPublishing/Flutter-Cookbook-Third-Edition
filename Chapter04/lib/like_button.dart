import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  int likes = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    debugPrint('LikeButton initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('LikeButton didChangeDependencies');
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('LikeButton didUpdateWidget');
  }

  @override
  void deactivate() {
    debugPrint('LikeButton deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('LikeButton dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LikeButton build');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.redAccent : Colors.grey,
          ),
          onPressed: () async {
            setState(() {
              isLiked = !isLiked;
              if (isLiked) {
                likes++;
              } else {
                likes--;
              }
            });
            await Future.delayed(const Duration(seconds: 2));
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Like saved!')));
          },
        ),
        Text('$likes likes'),
      ],
    );
  }
}
