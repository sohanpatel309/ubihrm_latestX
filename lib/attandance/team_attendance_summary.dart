import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawer.dart';
import 'home.dart';
import 'package:ubihrm/global.dart' as globals;
import 'package:ubihrm/services/attandance_services.dart';
import 'settings.dart';
import 'profile.dart';
import 'reports.dart';
import 'package:ubihrm/global.dart';
import 'package:ubihrm/b_navigationbar.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:ubihrm/profile.dart';
import '../appbar.dart';
import 'package:photo_view/photo_view.dart';
import './image_view.dart';
import 'attendance_summary.dart';
//import 'package:intl/intl.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'image_view.dart';
import '../global.dart';

void main() => runApp(new MyTeamAtt());

class MyTeamAtt extends StatefulWidget {
  @override
  _MyTeamAtt createState() => _MyTeamAtt();

}
TextEditingController today;

class _MyTeamAtt extends State<MyTeamAtt> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";
  String org_name="";
  int _currentIndex = 1;
  String admin_sts='0';
  bool _checkLoadedprofile = true;
  var profileimage;
  bool showtabbar ;
  String orgName="";
  bool res = true;
  var formatter = new DateFormat('dd-MMM-yyyy');

  bool _checkLoaded = true;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    getOrgName();

  }
  getOrgName() async{
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      orgName= prefs.getString('orgname') ?? '';
    });
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    profile = prefs.getString('profile') ?? '';
    //   profileimage = new NetworkImage(profile);
    // //print("1-"+profile);
    profileimage = new NetworkImage( globalcompanyinfomap['ProfilePic']);

    profileimage.resolve(new ImageConfiguration()).addListener((_, __) {
      if (mounted) {
        setState(() {
          _checkLoaded = false;
        });
      }
    });
    showtabbar=false;
    setState(() {
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      desination = prefs.getString('desination') ?? '';
      profile = prefs.getString('profile') ?? '';
      org_name = prefs.getString('org_name') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '';
    });
  }
  // This widget is the root of your application.
  Future<bool> sendToHome() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: ()=> sendToHome(),
        child: new Scaffold(
          backgroundColor:scaffoldBackColor(),
          endDrawer: new AppDrawer(),
          appBar: new AppHeader(profileimage,showtabbar,orgName),

          bottomNavigationBar:new HomeNavigation(),


          body: getWidgets(context),
        )
    );

  }
  getWidgets(context){
    return
      Container(
          margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          // width: MediaQuery.of(context).size.width*0.9,
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyApp()),
                                  );

                                },
                                child: const Text(
                                    'Self',
                                    style: TextStyle(fontSize: 18,color: Colors.orange,)
                                ),
                                // color: Colors.teal[50],
                                /* splashColor: Colors.white,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(0.0))*/
                                 ),
                                ]
                             ),
                              SizedBox(height:MediaQuery.of(context).size.width*.03),
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
                                  /* Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyTeamAtt()),
                                  );*/
                                  false;
                                },
                                child: const Text(
                                    'Team',
                                    style: TextStyle(fontSize: 18,color: Colors.orange,fontWeight:FontWeight.bold)
                                ),
                                //color: Colors.teal[50],

                                /* splashColor: Colors.white,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(0.0),

                                  /* side: BorderSide(
                                        color: Colors.blue,
                                        width: 1,

                                        style: BorderStyle.solid
                                    )*/
                                )*/
                              ),
                              ]),
                              SizedBox(height:MediaQuery.of(context).size.width*.03),
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
                    ]),
                /// My log start here

                Container(
                  padding: EdgeInsets.only(top:12.0,),
                  child:Center(
                    child:Text('Today Attendance Log',
                        style: new TextStyle(fontSize: 18.0, color: Colors.black87,)),
                  ),
                ),
                /*
                Container(
                  child: DateTimePickerFormField(
                    dateOnly: true,
                    format: formatter,
                    controller: today,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Icon(
                          Icons.date_range,
                          color: Colors.grey,
                        ), // icon is 48px widget.
                      ), // icon is 48px widget.
                      labelText: 'Select Date',
                    ),
                    onChanged: (date) {
                      setState(() {
                        if (date != null && date.toString() != '')
                          res = true; //showInSnackBar(date.toString());
                        else
                          res = false;
                      });
                    },
                    validator: (date) {
                      if (date == null) {
                        return 'Please select date';
                      }
                    },
                  ),
                ),*/

                /*Divider(
                color: Colors.green,
                height: 0.5,
              ),
              Divider(
                color: Colors.green,
                height: 0.5,
              ),*/
                /* Container(
                padding: EdgeInsets.only(top:12.0,bottom: 2.0),
                child:Center(
                  child:Text('Team Attendance Log',
                      style: new TextStyle(fontSize: 22.0, color: appStartColor(),)),
                ),
              ),*/
                //Divider(color: Colors.black54,height: 1.5,),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 40.0,),
                    SizedBox(width: MediaQuery.of(context).size.width*0.02),
                    Container(
                      width: MediaQuery.of(context).size.width*0.45,
                      child:Text('Name',style: TextStyle(color: Colors.green,fontWeight:FontWeight.bold,fontSize: 16.0),),
                    ),

                    SizedBox(height: 40.0,),
                    Container(
                      width: MediaQuery.of(context).size.width*0.2,
                      child:Text('Time In',style: TextStyle(color: Colors.green,fontWeight:FontWeight.bold,fontSize: 16.0),),
                    ),
                    SizedBox(height: 40.0,),
                    Container(
                      width: MediaQuery.of(context).size.width*0.2,
                      child:Text('Time Out',style: TextStyle(color: Colors.green,fontWeight:FontWeight.bold,fontSize: 16.0),),
                    ),
                  ],
                ),
                Divider(),
            new Expanded(
               child: res == true ? mainbody() : Center()
             ),
              ]

          ));
  }

  mainbody()
  {
    return Container(
              height: MediaQuery.of(context).size.height*0.60,
              child:
              FutureBuilder<List<User>>(
                future: getTeamSummary(),
                builder: (context, snapshot) {

                  if (snapshot.hasData) {
                    if(snapshot.data.length==0)
                    {
                      return new Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width*1,
                          color: Colors.teal.withOpacity(0.1),
                          padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                          child:Text("No Team Data Found ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                        ),
                      );
                    }
                    else
                      return new ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            //   double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
                            //   double f_width = MediaQuery.of(context).size.width*1; // screen's 100%


                            return new Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceAround,
                                    children: <Widget>[
                                      SizedBox(height: 40.0,),
                                      Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.40,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text(snapshot.data[index].EmpName
                                                .toString(), style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),),

                                            InkWell(
                                              child: Text('Time In: ' +
                                                  snapshot.data[index]
                                                      .checkInLoc.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.0)),
                                              onTap: () {
                                                goToMap(
                                                    snapshot.data[index]
                                                        .latit_in ,
                                                    snapshot.data[index]
                                                        .longi_in);
                                              },
                                            ),
                                            SizedBox(height:2.0),
                                            InkWell(
                                              child: Text('Time Out: ' +
                                                  snapshot.data[index]
                                                      .CheckOutLoc.toString(),
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12.0),),
                                              onTap: () {
                                                goToMap(
                                                    snapshot.data[index]
                                                        .latit_out,
                                                    snapshot.data[index]
                                                        .longi_out);
                                              },
                                            ),
                                            SizedBox(height:2.0),
                                            RichText(
                                              text: new TextSpan(
                                                // Note: Styles for TextSpans must be explicitly defined.
                                                // Child text spans will inherit styles from parent
                                                style: new TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black54,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                                  new TextSpan(text: snapshot.data[index]
                                                      .AttendanceStatus.toString(),style:TextStyle(color: Colors.black54,), ),
                                                ],
                                              ),
                                            ),

                                            snapshot.data[index]
                                                .bhour.toString()!=''?Container(
                                              color:Colors.orangeAccent,
                                              child:Text(""+snapshot.data[index]
                                                  .bhour.toString()+" Hr(s)",style: TextStyle(),),
                                            ):SizedBox(height: 10.0,),


                                          ],
                                        ),
                                      ),

                                      Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.22,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].TimeIn
                                                  .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                              GestureDetector(
                                                // When the child is tapped, show a snackbar
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: "UBIHRM")),
                                                  );
                                                },
                                                child:Container(
                                                  width: 62.0,
                                                  height: 62.0,
                                                  child: Container(
                                                      decoration: new BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          image: new DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: new NetworkImage(
                                                                  snapshot
                                                                      .data[index]
                                                                      .EntryImage)
                                                          )
                                                      )),),),

                                            ],
                                          )

                                      ),
                                      Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.22,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].TimeOut
                                                  .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                              GestureDetector(
                                                // When the child is tapped, show a snackbar
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: "UBIHRM")),
                                                  );
                                                },
                                                child:Container(
                                                  width: 62.0,
                                                  height: 62.0,
                                                  child: Container(
                                                      decoration: new BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          image: new DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: new NetworkImage(
                                                                  snapshot
                                                                      .data[index]
                                                                      .ExitImage)
                                                          )
                                                      )),),),

                                            ],
                                          )

                                      ),
                                    ],

                                  ),
                                  Divider(color: Colors.black26,),
                                ]);
                          }
                      );
                  } else if (snapshot.hasError) {
                    return new Text("Unable to connect server");
                  }

                  // By default, show a loading spinner
                  return new Center( child: CircularProgressIndicator());
                },
              )
          );
  }
}

class User {
  String AttendanceDate;
  String thours;
  String TimeOut;
  String TimeIn;
  String bhour;
  String EntryImage;
  String checkInLoc;
  String ExitImage;
  String CheckOutLoc;
  String latit_in;
  String longi_in;
  String latit_out;
  String longi_out;
  String AttendanceStatus;
  String EmpName;
  int id=0;
  User({this.AttendanceDate,this.thours,this.id,this.TimeOut,this.TimeIn,this.bhour,this.EntryImage,this.checkInLoc,this.ExitImage,this.CheckOutLoc,this.latit_in,this.longi_in,this.latit_out,this.longi_out,this.AttendanceStatus,this.EmpName});
}

String dateFormatter(String date_) {
  // String date_='2018-09-2';
  var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var dy = ['st', 'nd', 'rd', 'th', 'th', 'th','th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th','st','nd','rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th','st'];
  var date = date_.split("-");
  return(date[2]+""+dy[int.parse(date[2])-1]+" "+months[int.parse(date[1])-1]);
}


Future<List<User>> getTeamSummary() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  final response = await http.get(globals.path_ubiattendance+'getTeamHistory?uid=$empid&refno=$orgdir');
  print(globals.path_ubiattendance+'getTeamHistory?uid=$empid&refno=$orgdir');
  print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<User> userList = createUserList(responseJson);
  return userList;
}

List<User> createUserList(List data){
  List<User> list = new List();
  for (int i = 0; i < data.length; i++) {

    String title = Formatdate(data[i]["AttendanceDate"]);

    String TimeOut=data[i]["TimeOut"]=="00:00:00"?'-':data[i]["TimeOut"].toString().substring(0,5);
    String TimeIn=data[i]["TimeIn"]=="00:00:00"?'-':data[i]["TimeIn"].toString().substring(0,5);
    String thours = '';//data[i]["thours"]=="00:00:00"?'-':data[i]["thours"].toString().substring(0,5);

    String bhour=data[i]["bhour"]==null?'':'Time Off: '+data[i]["bhour"].substring(0,5);
    String EntryImage=data[i]["EntryImage"]!=''?data[i]["EntryImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String ExitImage=data[i]["ExitImage"]!=''?data[i]["ExitImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String checkInLoc=data[i]["checkInLoc"];
    String CheckOutLoc=data[i]["CheckOutLoc"];

    String Latit_in=data[i]["latit_in"];
    String Longi_in=data[i]["longi_in"];
    String Latit_out=data[i]["latit_out"];
    String Longi_out=data[i]["longi_out"];
    String Att_Sts=data[i]["AttendanceStatus"];
    String name=data[i]["EmpName"];

    int id = 0;
    User user = new User(EmpName:name,
        AttendanceDate: title,thours: thours,id: id,TimeOut:TimeOut,TimeIn:TimeIn,bhour:bhour,EntryImage:EntryImage,
        checkInLoc:checkInLoc,ExitImage:ExitImage,CheckOutLoc:CheckOutLoc,latit_in: Latit_in,longi_in: Longi_in,
        latit_out: Latit_out,longi_out: Longi_out, AttendanceStatus: Att_Sts);
    list.add(user);



  }
  return list;
}