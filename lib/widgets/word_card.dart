import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.wordStatus,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
  });

  final WordStatus wordStatus;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;
  
  @override
  WordCardState createState() => WordCardState();
}

class WordCardState extends State<WordCard> {
  
  bool liked = false;

  @override void initState() {
    liked = widget.wordStatus.liked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed(
          '/teachWord', 
          arguments:{'word': widget.wordStatus.word} 
        );
      },
      child: Container( 
        width: widget.sizedBoxWidth,
        height: widget.sizedBoxHeight,
        decoration: BoxDecoration(
          color: widget.wordStatus.learned ? "#F8F88E".toColor():"#F5F5DC".toColor(),
          borderRadius: BorderRadius.circular(12),
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
             Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  IconButton(
                    icon: liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                    iconSize: 16,
                    color: liked ? "#FF0303".toColor() : "#999999".toColor(),
                    onPressed: () async {
                      setState(() {
                        liked = !liked;
                      });
                      WordStatus newStatus = widget.wordStatus;
                      newStatus.liked = liked;
                      await WordStatusProvider.updateWordStatus(
                        status: newStatus
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 3, 0),
                    child: Icon(
                      widget.wordStatus.learned ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: widget.wordStatus.learned ? "#F8A339".toColor() : "#999999".toColor(),
                    ),
                  )
                ]
              ),
            ),
            Text(
              widget.wordStatus.word, 
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        )
      )
    );
  }
}

  
