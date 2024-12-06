import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Play_Audio.dart';
class ListCategory extends StatefulWidget {
  final podcasts;
  final docID;
  ListCategory({this.podcasts, this.docID});

  @override
  State<ListCategory> createState() => _ListCategoryState();
}

class _ListCategoryState extends State<ListCategory> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.purple, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network("${widget.podcasts["imageURL"]}",fit: BoxFit.fill,height: 80,)),
          ),
          Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayAudio(
                          audioURL: widget.podcasts["audioURL"],
                          imageURL: widget.podcasts["imageURL"],
                          user: widget.podcasts["user"],
                          title: widget.podcasts["title"],
                          docID: widget.docID),
                    ),
                  );
                  },
                child: ListTile(
                  title: Text("${widget.podcasts["title"]}",style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
                  subtitle: Text("${widget.podcasts["description"]}",style: TextStyle(color: Colors.white),),

                ),
              ))
        ],
      ),
    );
  }
}
