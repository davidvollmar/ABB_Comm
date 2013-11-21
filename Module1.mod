MODULE Module1
    
    VAR pos TargetData;

    VAR robtarget p10;
    VAR robtarget p11;

    VAR socketdev client_socket;
    VAR string received_string;
    VAR string rec_str;

    VAR string separator:=";";
    VAR string end:="#";

    !false is open
    VAR bool gripperState:=FALSE;
    VAR bool lastGripperState:=FALSE;


    PROC main()
        rec_targets2;
    ENDPROC

    FUNC pos parseTarget(string s)
        VAR num index;
        VAR num len;
        VAR num x;
        VAR num y;
        VAR num z;
        VAR string str_x;
        VAR string str_y;
        VAR string str_z;
        VAR string str_buf;
        VAR bool b_x;
        VAR bool b_y;
        VAR bool b_z;
        VAR pos tData;
        len:=StrLen(s);
        index:=StrMatch(s,1,separator);

        str_x:=StrPart(s,1,index-1);
        str_buf:=StrPart(s,index+1,len-index);
        len:=StrLen(str_buf);
        index:=StrMatch(str_buf,1,separator);

        str_y:=StrPart(str_buf,1,index-1);
        str_buf:=StrPart(str_buf,index+1,len-index);
        index:=StrMatch(str_buf,1,separator);
        str_z:=StrPart(str_buf,1,index-1);

        b_x:=StrToVal(str_x,x);
        b_y:=StrToVal(str_y,y);
        b_z:=StrToVal(str_z,z);

        tData.x:=x;
        tData.y:=y;
        tData.z:=z;

        IF b_x AND b_y AND b_z THEN
            RETURN tData;
        ENDIF

        !todo foutafhandeling
    ERROR
        RAISE ;

        RETURN [-1,-1,-1];
    ENDFUNC

    FUNC bool parseGripper(string s)
        VAR num index:=0;
        index:=strFind(s,1,"O");
        RETURN index=(StrLen(s)+1);
        !strlen(s)+1 geeft aan dat er geen karacter in die string gevonden is.        
    ENDFUNC

    PROC rec_targets2()
        VAR string buf2;

        SocketCreate client_socket;
        SocketConnect client_socket,"192.168.125.4",1025;

        SocketSend client_socket\Str:="&";

        WHILE TRUE DO
            SocketReceive client_socket\Str:=rec_str\ReadNoOfBytes:=1;
            IF rec_str=end THEN
                TPWrite "Client wrote X: "+buf2+end;
                SocketSend client_socket\Str:="DEBUG "+buf2+end;
                TargetData:=parseTarget(buf2+end);
                gripperState:=parseGripper(buf2);
                TPWrite "The target Coordinate X-axis is: "\Num:=TargetData.x;
                TPWrite "The target Coordinate Y-axis is: "\Num:=TargetData.y;
                TPWrite "The target Coordinate Z-axis is: "\Num:=TargetData.z;
                buf2:="";
                user_selectionStart;
                SocketSend client_socket\Str:="&";
            ELSE
                buf2:=buf2+rec_str;
            ENDIF
        ENDWHILE

        SocketClose client_socket;

        ERROR
            IF ERRNO = ERR_SOCK_TIMEOUT THEN
                TPWrite "Socket Connection Timed out.";
            ELSEIF ERRNO = ERR_SOCK_ADDR_INUSE THEN
                TPWrite "The Socket addres is already in use";
            ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
                TPWrite "The Socked Connection was closed";
            ELSE
                !no error handling.
            ENDIF
    ENDPROC


    PROC user_selectionStart()
        TPWrite "The CURRENT COORDINATES---->";
        TPWrite "The target Coordinate X-axis is: "\Num:=TargetData.x;
        TPWrite "The target Coordinate Y-axis is: "\Num:=TargetData.y;
        TPWrite "The target Coordinate Z-axis is: "\Num:=TargetData.z;
        
        pick_object;
    ENDPROC

    PROC pick_object()
        p10:=[[TargetData.x,TargetData.y,TargetData.z+40],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
        !Sets P10 with vison coordinates  
        p11:=[[TargetData.x,TargetData.y,TargetData.z],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
        !Sets P10 with vison coordinates 
        !MoveJ p10,v100,fine,TCP_RobotGripper\WObj:=wobj_vision;
        !Moves to P10
        MoveJ p11,v100,fine,TCP_RobotGripper\WObj:=wobj_vision;
        !Moves to P11

        !        WaitTime 0.3;
        !        Set DO10_1;
        !        !set close gripper
        !        WaitTime 0.3;
        !        Reset DO10_1;
        !        !reset close gripper
        !
        !        !MoveAbsJ HomeTarget,v500,fine00,TCP_RobotGripper\WObj:=wobj_vision;
        !        !Move to home
        !        WaitTime 0.3;
        !        Set DO10_2;
        !        !set open gripper
        !        WaitTime 0.3;
        !        Reset DO10_2;
        !        !reset open gripper

        IF gripperState<>lastGripperState THEN
            IF gripperState THEN
                !close gripper
                WaitTime 0.3;
                Set DO10_1;
                !set close gripper
                WaitTime 0.3;
                Reset DO10_1;
                !reset close gripper
            ELSE
                !open gripper
                WaitTime 0.3;
                Set DO10_2;
                !set open gripper
                WaitTime 0.3;
                Reset DO10_2;
                !reset open gripper
            ENDIF
            lastGripperState:=gripperState;
        ENDIF

    ENDPROC





ENDMODULE