import 'package:flutter/material.dart';
import '../drawer.dart';
import '../graphs.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../global.dart';
import '../services/leave_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import '../model/model.dart';
import 'requestleave.dart';
import 'teamleave.dart';
import 'approval.dart';
import '../home.dart';
import '../profile.dart';
//import 'bottom_navigationbar.dart';
import '../b_navigationbar.dart';
import '../appbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class MyLeave extends StatefulWidget {
  @override
  _MyLeaveState createState() => _MyLeaveState();
}

class _MyLeaveState extends State<MyLeave> {
  int _currentIndex = 0;
  int response;
  var profileimage;
  bool showtabbar ;
  String orgName="";

  bool _checkLoadedprofile = true;
  bool _checkwithdrawnleave = false;
  var PerLeave;
  var PerApprovalLeave;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  Widget mainWidget= new Container(width: 0.0,height: 0.0,);
  @override
  void initState() {
    super.initState();
    profileimage = new NetworkImage( globalcompanyinfomap['ProfilePic']);
    profileimage.resolve(new ImageConfiguration()).addListener((_, __) {
      if (mounted) {
        setState(() {
          _checkLoadedprofile = false;
        });

      }
    });
    showtabbar=false;
  //  print(profileimage);
    initPlatformState();
    getOrgName();
  }

  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orgName= prefs.getString('orgname') ?? '';
    });
  }

  initPlatformState() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      mainWidget = loadingWidget();
    });
    String empid = prefs.getString('employeeid')??"";
    String organization =prefs.getString('organization')??"";
    islogin().then((Widget configuredWidget) {
      setState(() {
        mainWidget = configuredWidget;
      });
    });
  }
  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
    ));
  }

  withdrawlLeave(String leaveid) async{
    setState(() {
      _checkwithdrawnleave = true;
    });
    print("----> withdrawn service calling "+_checkwithdrawnleave.toString());
    final prefs = await SharedPreferences.getInstance();

    String empid = prefs.getString('employeeid')??"";
   String orgid =prefs.getString('organization')??"";
    var leave = Leave(leaveid: leaveid, orgid: orgid, uid: empid, approverstatus: '5');
    var islogin = await withdrawLeave(leave);
    print(islogin);
    if(islogin=="success"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLeave()),
      );
      showDialog(context: context, child:
      new AlertDialog(
      //  title: new Text("Congrats!"),
        content: new Text("Your leave is withdrawn successfully!"),
      )
      );
    }else if(islogin=="failure"){
      showDialog(context: context, child:
      new AlertDialog(
        //title: new Text("Sorry!"),
        content: new Text("Leave could not be withdrawn."),
      )
      );
    }else{
      showDialog(context: context, child:
      new AlertDialog(
       // title: new Text("Sorry!"),
        content: new Text("Poor network connection."),
      )
      );
    }
  }

  confirmWithdrawl(String leaveid) async{
    showDialog(context: context, child:
    new AlertDialog(
      title: new Text("Withdraw  leave?"),
      content:  ButtonBar(
        children: <Widget>[
          FlatButton(
            shape: Border.all(),
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          RaisedButton(
            child: Text('Withdraw',style: TextStyle(color: Colors.white),),
            color: Colors.orange[800],
            onPressed: () {
              setState(() {
                _checkwithdrawnleave = true;
              });
              Navigator.of(context, rootNavigator: true).pop();
              withdrawlLeave(leaveid);

            },
          ),
        ],
      ),
    )
    );
  }


  Future<Widget> islogin() async{
    final prefs = await SharedPreferences.getInstance();
    int response = prefs.getInt('response')??0;
    if(response==1){
      return mainScafoldWidget();
    }else{
      return new LoginPage();
    }

  }

  @override
  Widget build(BuildContext context) {

    return mainWidget;
  }


  Widget loadingWidget(){
    return Center(child:SizedBox(
      child:
      Text("Loading..", style: TextStyle(fontSize: 10.0,color: Colors.white),),
    ));
  }

  Widget mainScafoldWidget(){
    return  Scaffold(
        backgroundColor:scaffoldBackColor(),
        endDrawer: new AppDrawer(),
        appBar: new AppHeader(profileimage,showtabbar,orgName),
        bottomNavigationBar:new HomeNavigation(),
      body:  ModalProgressHUD(
          inAsyncCall: _checkwithdrawnleave,
          opacity: 0.15,
          progressIndicator: SizedBox(
            child:new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation(Colors.green),
                strokeWidth: 5.0),
            height: 50.0,
            width: 50.0,
          ),
          child: homewidget()
      ),
         floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.orange[800],
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RequestLeave()),
            );
          },
          tooltip: 'Request Leave',
          child: new Icon(Icons.add),
        ),

    );
  }

  Widget homewidget(){
    return Stack(
      children: <Widget>[
        Container(
          //height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //width: MediaQuery.of(context).size.width*0.9,
            decoration: new ShapeDecoration(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
              color: Colors.white,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex:48,
                        child:Column(
                            children: <Widget>[
                              // width: double.infinity,
                              //height: MediaQuery.of(context).size.height * .07,
                              SizedBox(height:MediaQuery.of(context).size.width*.02),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                        Icons.person,
                                        color: Colors.orange,
                                        size: 22.0 ),
                                    GestureDetector(
                                      onTap: () {
                                        false;
                                      },

                                      child: const Text(
                                          'Self',
                                          style: TextStyle(fontSize: 18,color: Colors.orange,fontWeight:FontWeight.bold)
                                      ),
                                    ),
                                  ]),

                              SizedBox(height:MediaQuery.of(context).size.width*.036),
                              Divider(
                                color: Colors.orange,
                                height: 0.4,
                              ),
                              Divider(
                                color: Colors.orange,
                                height: 0.4,
                              ),
                              Divider(
                                color: Colors.orange,
                                height: 0.4,
                              ),
                            ]
                        ),
                      ),

                      Expanded(
                        flex:48,
                        child: Column(
                          // width: double.infinity,
                            children: <Widget>[
                              SizedBox(height:MediaQuery.of(context).size.width*.02),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                        Icons.group,
                                        color: Colors.orange,
                                        size: 22.0 ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MyTeamLeave()),
                                        );
                                      },
                                      child: const Text(
                                          'Team',
                                          style: TextStyle(fontSize: 18,color: Colors.orange)
                                      ),
                                    ),
                                  ]),
                              SizedBox(height:MediaQuery.of(context).size.width*.04),
                            ]
                        ),
                      )
                    ]
                ),

                Container(
                  padding: EdgeInsets.only(top:12.0),
                  child:Center(
                    child:Text('My Leave',
                        style: new TextStyle(fontSize: 18.0, color: Colors.black87,)),
                  ),
                ),


                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //            crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 50.0,),
                    // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                    new Expanded(
                      child: Container(
                        color: Colors.red,
                        width: MediaQuery.of(context).size.width*0.50,
                        child:Text('Applied on',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),),

                    //SizedBox(height: 50.0,),

                    new Expanded(
                      child: Container(
                        color: Colors.yellow,
                        width: MediaQuery.of(context).size.width*0.50,
                        margin: EdgeInsets.only(left:22.0),
                        child:Text('Duration',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0,),textAlign: TextAlign.center,),
                      ),
                    ),


                  ],
                ),

                new Divider(),

                new Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height*.55,
                    width: MediaQuery.of(context).size.width*.99,
                    //padding: EdgeInsets.only(bottom: 15.0),
                    color: Colors.white,
                    //////////////////////////////////////////////////////////////////////---------------------------------
                    child: new FutureBuilder<List<Leave>>(
                      future: getLeaveSummary(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length>0) {
                            return new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            new Expanded(
                                              child: Container(color: Colors.red,
                                                  width: MediaQuery .of(context).size .width * 0.45,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      new SizedBox(width: 5.0,),
                                                      new Text(snapshot.data[index].attendancedate.toString(), style: TextStyle(fontWeight: FontWeight.bold),)
                                                    ],
                                                  )
                                              ),
                                            ),

                                            new Expanded(
                                              child: Container(color: Colors.yellow,
                                                  width: MediaQuery .of(context).size .width * 0.45,
                                                  margin: EdgeInsets.only(left:22.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      new SizedBox(width: 5.0,),
                                                      new Text(snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]),textAlign: TextAlign.center,)
                                                    ],
                                                  )
                                              ),
                                            ),

                                           /* new Container(
                                                child: RichText(
                                                  text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(text: ''
                                                          ,style: new TextStyle(fontWeight: FontWeight.bold)),
                                                      new TextSpan(text: snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]), ),

                                                    ],
                                                  ),
                                                )
                                            ),*/

                                         /*   new Expanded(
                                              child: Container(
                                                  width: MediaQuery .of(context).size.width * 0.45,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      new SizedBox(width: 5.0,),
                                                      new Text(
                                                        "",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold),),
                                                      (snapshot.data[index].withdrawlsts &&
                                                          snapshot.data[index].approverstatus.toString() !='Withdrawn' && snapshot.data[index].approverstatus.toString() !=
                                                          "Rejected") ? new Container(
                                                          height: 30.5,
                                                          margin: EdgeInsets.only(
                                                              left:25.0),
                                                          child: new OutlineButton(
                                                            child:new Icon(Icons.replay, size: 18.0,color:appStartColor(), ),
                                                            borderSide: BorderSide(color:appStartColor()),

                                                            //  color: Colors.orangeAccent,
                                                            onPressed: () {
                                                              confirmWithdrawl(
                                                                  snapshot.data[index].leaveid.toString());},
                                                            shape: new CircleBorder(),
                                                          )
                                                      ) : Center()
                                                    ],
                                                  )
                                              ),
                                            ),*/
                                          ],
                                        ),

                                        snapshot.data[index].reason.toString()!='-'?Container(
                                          width: MediaQuery.of(context).size.width*.90,
                                          padding: EdgeInsets.only(top:1.5,bottom: .5),
                                          margin: EdgeInsets.only(top: 4.0),
                                          child: Text('Reason: '+snapshot.data[index].reason.toString(), style: TextStyle(color: Colors.black54),),
                                        ):Center(),

                                        snapshot.data[index].comment.toString() != '-' ? Container(
                                          width: MediaQuery .of(context).size .width * .90,
                                          padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                          margin: EdgeInsets.only(top: 0.0),
                                          child: Text('Approver Comment: ' +  snapshot.data[index].comment.toString(),style: TextStyle(color: Colors.black54),),
                                        ): Center(),

                                        snapshot.data[index].approverstatus.toString()!='-'?Container(
                                          width: MediaQuery.of(context).size.width*.90,
                                          padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                          margin: EdgeInsets.only(top: 1.0),
                                          child: RichText(
                                            text: new TextSpan(
                                              // Note: Styles for TextSpans must be explicitly defined.
                                              // Child text spans will inherit styles from parent
                                              style: new TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                                new TextSpan(text: snapshot.data[index].approverstatus.toString(), style: TextStyle(color: snapshot.data[index].approverstatus.toString()=='Approved'?appStartColor() :snapshot.data[index].approverstatus.toString()=='Rejected' || snapshot.data[index].approverstatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].approverstatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                              ],
                                            ),
                                          ),
                                        ):Center(
                                          // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                        ),

                                        Divider(color: Colors.grey,),
                                      ]);
                                }
                            );
                          }else
                            return new Center( child: Text('No Leave History'), );
                        } else if (snapshot.hasError) {
                          return new Text("Unable to connect server");
                        }

                        // By default, show a loading spinner
                        return new Center( child: CircularProgressIndicator());
                      },
                    ),
                    //////////////////////////////////////////////////////////////////////---------------------------------
                  ),
                ),


////////////////////////OLD DESIGN////////////////////
/*                new Row(
                mainAxisAlignment: MainAxisAlignment.start,
            //            crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                SizedBox(height: 50.0,),
                // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                new Expanded(
                child: Container(
                width: MediaQuery.of(context).size.width*0.45,
                child:Text('Applied on',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                ),),

                //SizedBox(height: 50.0,),

                new Expanded(
                child: Container(
                width: MediaQuery.of(context).size.width*0.20,
                margin: EdgeInsets.only(left:22.0),
                child:Text('Duration',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                ),
                ),

                new Expanded(
                child: Container(
                margin: EdgeInsets.only(left:42.0),
                width: MediaQuery.of(context).size.width*0.30,
                child:Text('Action',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                ),),
                ],
                ),

                new Divider(),

                new Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height*.55,
                    width: MediaQuery.of(context).size.width*.99,
                    //padding: EdgeInsets.only(bottom: 15.0),
                    color: Colors.white,
                //////////////////////////////////////////////////////////////////////---------------------------------
                    child: new FutureBuilder<List<Leave>>(
                       future: getLeaveSummary(),
                       builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length>0) {
                            return new ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                              return new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: Container(
                                        width: MediaQuery .of(context).size .width * 0.35,
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(width: 5.0,),
                                            new Text(snapshot.data[index].attendancedate.toString(), style: TextStyle(fontWeight: FontWeight.bold),)
                                          ],
                                        )
                                      ),
                                    ),

                                    new Container(
                                      child: RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                          new TextSpan(text: ''
                                          ,style: new TextStyle(fontWeight: FontWeight.bold)),
                                          new TextSpan(text: snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]), ),

                                          ],
                                        ),
                                      )
                                    ),

                                    new Expanded(
                                      child: Container(
                                        width: MediaQuery .of(context).size.width * 0.30,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(width: 5.0,),
                                            new Text(
                                            "",
                                            style: TextStyle(
                                            fontWeight: FontWeight.bold),),
                                            (snapshot.data[index].withdrawlsts &&
                                            snapshot.data[index].approverstatus.toString() !='Withdrawn' && snapshot.data[index].approverstatus.toString() !=
                                            "Rejected") ? new Container(
                                            height: 30.5,
                                            margin: EdgeInsets.only(
                                            left:25.0),
                                            child: new OutlineButton(
                                            child:new Icon(Icons.replay, size: 18.0,color:appStartColor(), ),
                                            borderSide: BorderSide(color:appStartColor()),

                                            //  color: Colors.orangeAccent,
                                            onPressed: () {
                                            confirmWithdrawl(
                                            snapshot.data[index].leaveid.toString());},
                                            shape: new CircleBorder(),
                                            )
                                            ) : Center()
                                          ],
                                        )
                                      ),
                                    ),
                                  ],
                                ),

                                snapshot.data[index].reason.toString()!='-'?Container(
                                width: MediaQuery.of(context).size.width*.90,
                                padding: EdgeInsets.only(top:1.5,bottom: .5),
                                margin: EdgeInsets.only(top: 4.0),
                                child: Text('Reason: '+snapshot.data[index].reason.toString(), style: TextStyle(color: Colors.black54),),
                                ):Center(),

                                snapshot.data[index].comment.toString() != '-' ? Container(
                                width: MediaQuery .of(context).size .width * .90,
                                padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                margin: EdgeInsets.only(top: 0.0),
                                child: Text('Approver Comment: ' +  snapshot.data[index].comment.toString(),style: TextStyle(color: Colors.black54),),
                                ): Center(),

                                snapshot.data[index].approverstatus.toString()!='-'?Container(
                                width: MediaQuery.of(context).size.width*.90,
                                padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                margin: EdgeInsets.only(top: 1.0),
                                child: RichText(
                                text: new TextSpan(
                                // Note: Styles for TextSpans must be explicitly defined.
                                // Child text spans will inherit styles from parent
                                style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                ),
                                children: <TextSpan>[
                                new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                new TextSpan(text: snapshot.data[index].approverstatus.toString(), style: TextStyle(color: snapshot.data[index].approverstatus.toString()=='Approved'?appStartColor() :snapshot.data[index].approverstatus.toString()=='Rejected' || snapshot.data[index].approverstatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].approverstatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                ],
                                ),
                                ),
                                ):Center(
                                // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                ),

                                Divider(color: Colors.grey,),
                              ]);
                            }
                          );
                        }else
                          return new Center( child: Text('No Leave History'), );
                        } else if (snapshot.hasError) {
                          return new Text("Unable to connect server");
                        }

                // By default, show a loading spinner
                        return new Center( child: CircularProgressIndicator());
                    },
                ),
                //////////////////////////////////////////////////////////////////////---------------------------------
                ),
                ),*/
//////////////OLD DESIGN///////////

              ]
            )



    ///////////////////TESTING//////////////////////////



/*
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('My Leave',
                   style: new TextStyle(fontSize: 22.0, color: appStartColor())),
                  //SizedBox(height: 10.0),

                  new Divider(color: Colors.black54,height: 1.5,),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 50.0,),
                     // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                      new Expanded(
                        child: Container(
                        width: MediaQuery.of(context).size.width*0.45,
                        child:Text('Applied on',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),),

                      //SizedBox(height: 50.0,),

                      new Expanded(
                        child: Container(
                        width: MediaQuery.of(context).size.width*0.20,
                          margin: EdgeInsets.only(left:22.0),
                        child:Text('Duration',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),
        ),

                      new Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left:42.0),
                        width: MediaQuery.of(context).size.width*0.30,
                        child:Text('Action',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),),
                    ],
                  ),
                  new Divider(),
                  new Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height*.55,
                      width: MediaQuery.of(context).size.width*.99,
                      //padding: EdgeInsets.only(bottom: 15.0),
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Leave>>(
                        future: getLeaveSummary(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                 children: <Widget>[
                                   new Expanded(
                                     child: Container(
                                      width: MediaQuery .of(context).size .width * 0.35,
                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                          new SizedBox(width: 5.0,),
                                          new Text(
                                          snapshot.data[index].attendancedate.toString(),
                                          style: TextStyle(
                                          fontWeight: FontWeight.bold),)

                                        ],
                                        )),),




                                   new Container(
                                       child: RichText(
                                         text: new TextSpan(
                                           style: new TextStyle(
                                             fontSize: 14.0,
                                             color: Colors.black,
                                           ),
                                           children: <TextSpan>[
                                             new TextSpan(text: ''
                                                 ,style: new TextStyle(fontWeight: FontWeight.bold)),
                                             new TextSpan(text: snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]), ),

                                           ],
                                         ),
                                       )
                                   ),

                                   new Expanded(
                                     child: Container(
                                      width: MediaQuery .of(context).size.width * 0.30,
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                             new SizedBox(width: 5.0,),
                                             new Text(
                                               "",
                                             style: TextStyle(
                                                 fontWeight: FontWeight.bold),),
                                             (snapshot.data[index].withdrawlsts &&
                                              snapshot.data[index].approverstatus.toString() !='Withdrawn' && snapshot.data[index].approverstatus.toString() !=
                                                 "Rejected") ? new Container(
                                                 height: 30.5,
                                                 margin: EdgeInsets.only(
                                                 left:25.0),
                                                 child: new OutlineButton(
                                                 child:new Icon(Icons.replay, size: 18.0,color:appStartColor(), ),
                                                borderSide: BorderSide(color:appStartColor()),

                                                   //  color: Colors.orangeAccent,
                                                 onPressed: () {
                                                 confirmWithdrawl(
                                                 snapshot.data[index].leaveid.toString());},
                                                 shape: new CircleBorder(),
                                                 )
                                             ) : Center()
                                           ],
                                         )




                                     ),),




                                            ],
                                          ),
                                          //SizedBox(width: 30.0,),


                                          snapshot.data[index].reason.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:1.5,bottom: .5),
                                            margin: EdgeInsets.only(top: 4.0),
                                            child: Text('Reason: '+snapshot.data[index].reason.toString(), style: TextStyle(color: Colors.black54),),
                                          ):Center(),





                                          snapshot.data[index].comment.toString() != '-' ? Container(
                                            width: MediaQuery .of(context).size .width * .90,
                                            padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                            margin: EdgeInsets.only(top: 0.0),
                                            child: Text('Approver Comment: ' +  snapshot.data[index].comment.toString(),style: TextStyle(color: Colors.black54),),
                                          ): Center(),



                                          snapshot.data[index].approverstatus.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                            margin: EdgeInsets.only(top: 1.0),
                                            child: RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                                  new TextSpan(text: snapshot.data[index].approverstatus.toString(), style: TextStyle(color: snapshot.data[index].approverstatus.toString()=='Approved'?appStartColor() :snapshot.data[index].approverstatus.toString()=='Rejected' || snapshot.data[index].approverstatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].approverstatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                                ],
                                              ),
                                            ),
                                          ):Center(
                                            // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                          ),

                                          Divider(color: Colors.grey,),
                             ]);
                              }
                          );
                          }else
                           return new Center(
                             child: Text('No Leave History'),
                           );
                          } else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                    // By default, show a loading spinner
                    return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ])*/

    ///////////////////TESTING//////////////////////////


        ),



      ],
    );
  }



}
