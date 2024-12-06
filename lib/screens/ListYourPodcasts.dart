import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/screens/Edit_Podcast.dart';

import 'Play_Audio.dart';

class ListYourPodcasts extends StatefulWidget {
  final podcasts;
  final Future<void> Function() onDelete;
  final docID;
  ListYourPodcasts({required this.podcasts,required this.onDelete,this.docID});

  @override
  State<ListYourPodcasts> createState() => _ListPodcastsState();
}

class _ListPodcastsState extends State<ListYourPodcasts> {

  CollectionReference podRef = FirebaseFirestore.instance.collection("Podcast");

  // delete(var date , var description)async{
  //   podRef.where('Date', isEqualTo: date).where('description', isEqualTo: description)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       doc.reference.delete();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Document successfully deleted'),backgroundColor: Colors.green,),
  //       );
  //     });
  //   }).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error deleting document: $error'),backgroundColor: Colors.green,),
  //     );
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return  Card(
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
                          docID: widget.docID,),
                    ),
                  );
                },
                child: ListTile(
                  title: Text("${widget.podcasts["title"]}",style: GoogleFonts.actor(fontSize: 20,color: Colors.white),),
                  subtitle: Text("${widget.podcasts["description"]}",style: TextStyle(color: Colors.white),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mode_edit_outline,color: Colors.purple),
                        onPressed: (){Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPodcast(
                                title: widget.podcasts["title"],
                                description: widget.podcasts["description"],
                                imageURL: widget.podcasts["imageURL"],
                                audioUrl: widget.podcasts["audioURL"],
                                category: widget.podcasts["category"],
                                date: widget.podcasts["Date"],),
                          ),
                        );},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_outlined,color: Colors.purple),
                        onPressed: ()async{
                          bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                          return AlertDialog(
                          title: Text('Confirm Delete',style: TextStyle(color: Colors.white),),
                          content: Text('Are you sure you want to delete this podcast?',style: TextStyle(color: Colors.white),),
                          actions: [
                          TextButton(
                          onPressed: () {
                          Navigator.of(context).pop(false); // User canceled the deletion
                          },
                          child: Text('Cancel'),
                          ),
                          TextButton(
                          onPressed: () {
                          Navigator.of(context).pop(true); // User confirmed the deletion
                          },
                          child: Text('Delete',style: TextStyle(color: Colors.red),),
                          ),

                          ], shape: const RoundedRectangleBorder(
                          ), backgroundColor: Colors.grey[900],
                            elevation: 8.0,
                          );
                          },
                          );

                          if (confirm == true){
                          FirebaseStorage storage = FirebaseStorage.instance;
                          Reference ref1 = storage.refFromURL(widget.podcasts["imageURL"]);
                          await ref1.delete().then((_) {
                            print('===================Image deleted successfully========================');
                          }).catchError((error) {
                            print('======================Error deleting image: $error=========================');
                          });
                          Reference ref2 = storage.refFromURL(widget.podcasts["audioURL"]);
                          await ref2.delete().then((_) {
                            print('===================Audio deleted successfully========================');
                          }).catchError((error) {
                            print('======================Error deleting audio: $error=========================');
                          });
                          await podRef.where('Date', isEqualTo: widget.podcasts["Date"]).where('description', isEqualTo: widget.podcasts["description"])
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            querySnapshot.docs.forEach((doc) {
                              doc.reference.delete();
                              widget.onDelete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Document successfully deleted'),backgroundColor: Colors.green,),
                              );
                            });
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting document: $error'),backgroundColor: Colors.green,),
                            );
                          });}
                        }
                        //widget.podcasts["Date"],widget.podcasts["description",
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
