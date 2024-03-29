import 'package:flutter/material.dart';
import '../drawer.dart';
import '../graphs.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../global.dart';
import '../services/leave_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import '../model/model.dart';
import 'request_expense.dart';
import '../home.dart';
import '../services/expense_services.dart';
//import 'bottom_navigationbar.dart';
import '../b_navigationbar.dart';
import '../appbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class MyExpence extends StatefulWidget {
  @override
  _MyExpenceState createState() => _MyExpenceState();
}

class _MyExpenceState extends State<MyExpence> {
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
     /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLeave()),
      );*/
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
           MaterialPageRoute(builder: (context) => RequestExpence()),
         );
        },
        tooltip: 'Submit Expenses',
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
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('My Expenses',
                      style: new TextStyle(fontSize: 22.0, color: appStartColor())),
                  //SizedBox(height: 10.0),



                  new Divider(),
                  new Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height*.55,
                      width: MediaQuery.of(context).size.width*.99,
                      //padding: EdgeInsets.only(bottom: 15.0),
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------


                      child: new FutureBuilder<List<Expensedate>>(
                        future: getExpenselistbydate(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                     // mainAxisAlignment: MainAxisAlignment.start,

                                        children: <Widget>[
                                         new RaisedButton(
                                            //   shape: BorderDirectional(bottom: BorderSide(color: Colors.green[900],style: BorderStyle.solid,width: 1),top: BorderSide(color: Colors.green[900],style: BorderStyle.solid,width: 1)),
                                            //   shape: RoundedRectangleBorder(side: BorderSide(color: appStartColor(),style: BorderStyle.solid,width: 1),borderRadius: new BorderRadius.circular(5.0)),
                                            //   shape: RoundedRectangleBorder(side: BorderSide(color:appStartColor(),style: BorderStyle.solid,width: 1)),
                                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                                  padding: EdgeInsets.only(left:  0.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                SizedBox(width: 15.0),
                                                  Expanded(

                                                       child: Container(
                                                            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                                            child: Text(snapshot.data[index].dates.toString(),textAlign:TextAlign.left,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 15.0),)
                                                        ),


                                                  ),

                                                  /*Container(
                                                    child: Icon(Icons.keyboard_arrow_down,size: 40.0,),
                                                  ),*/
                                                ],
                                              ),
                                            ),
                                            color: Colors.white,
                                            elevation: 4.0,
                                            textColor: Colors.black,
                                            onPressed: () {
                                         //     expensebydatewidget();
                                             // Navigator.push(
                                             //   context,
                                            //    MaterialPageRoute(builder: (context) => LeaveReports()),
                                            //  );
                                            },
                                          ),
                                         expensebydatewidget(snapshot.data[index].Fdate.toString()),

                                     ]);
                                  }
                              );
                            }else
                              return new Center(
                                child: Text('No Expense History'),
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
                ])
        ),



      ],
    );
  }

  Widget expensebydatewidget(Fdate){
    return
 Container(
     color: Colors.green[100],
     // height: MediaQuery.of(context).size.height*0.2,
     child:  Column(

    mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[

          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0,),
              // SizedBox(width: MediaQuery.of(context).size.width*0.0),

              new Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.45,
                  child:Text('  Category',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 14.0),),
                ),),
              /*  new Expanded(
                        child: Container(
                        width: MediaQuery.of(context).size.width*0.35,),),
                    SizedBox(height: 50.0,),
                      Container(
                        width: MediaQuery.of(context).size.width*0.25,
                        child:Text('From',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),*/
              //SizedBox(height: 50.0,),
              new Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.20,
                  margin: EdgeInsets.only(left:20.0),
                  child:Text('Description',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 14.0),),
                ),
              ),

              new Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.20,
                  margin: EdgeInsets.only(left:40.0),
                  child:Text('Amount',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 14.0),),
                ),
              ),


            ] , ),

          new Row(
              mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                new Expanded(
                  child: Container(
                   height: MediaQuery.of(context).size.height*.10,
                    width: MediaQuery.of(context).size.width*.99,
                    //padding: EdgeInsets.only(bottom: 15.0),
                    color: Colors.green[50],
                    //////////////////////////////////////////////////////////////////////---------------------------------


                    child: new FutureBuilder<List<Expense>>(
                      future: getExpenselist(Fdate),
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
                                                    margin: EdgeInsets.only(top:2.0,left:8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        new SizedBox(width: 5.0,),
                                                        new Text(snapshot.data[index].category.toString(),
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold),)

                                                      ],
                                                    )
                                                ),
                                              ),

                                              new Expanded(
                                                child: Container(
                                                    width: MediaQuery .of(context).size .width * 0.35,
                                                    margin: EdgeInsets.only(left:20.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        new SizedBox(width: 5.0,),
                                                        new Text(
                                                          snapshot.data[index].desc.toString(),
                                                          style: TextStyle(
                                                              ),)

                                                      ],
                                                    )
                                                ),
                                              ),
                                              new Expanded(
                                                child: Container(
                                                    width: MediaQuery .of(context).size .width * 0.35,
                                                    margin: EdgeInsets.only(left:40.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        new SizedBox(width: 5.0,),
                                                        new Text(
                                                         snapshot.data[index].amt.toString()+ "  "+snapshot.data[index].currency.toString(),textAlign: TextAlign.right,

                                                         //   snapshot.data[index].amt.toString() ,textAlign: TextAlign.right,

                                                        )

                                                      ],
                                                    )
                                                ),
                                              ),

                                            ],
                                          ),



                                        ////

                                        /*   snapshot.data[index].desc.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:1.5,bottom: .5),
                                            margin: EdgeInsets.only(top: 4.0),
                                            child: Text(snapshot.data[index].category.toString(), style: TextStyle(color: Colors.black54),),
                                          ):Center(),*/

                                        /*  snapshot.data[index].desc.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:1.5,bottom: 1.5),
                                            margin: EdgeInsets.only(top: 4.0,bottom: 1.5),
                                            child: Text('Description: '+snapshot.data[index].desc.toString(), style: TextStyle(color: Colors.black54),),
                                          ):Center(),*/



                                      ]);
                                }
                            );
                          }else
                            return new Center(
                              child: Text('No Expense History'),
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

              ]),


        ] ) );

  }

}
