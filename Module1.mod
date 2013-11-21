MODULE Module1
	CONST jointtarget HomeTarget:=[[90,0,45,0,24,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
	CONST jointtarget HomeTarget_Mirror:=[[-90,0,45,0,24,0],[9E9,9E9,9E9,9E9,9E9,9E9]];
PROC Path_10()
	MoveAbsJ HomeTarget,v1000,z100,TCP_RobotGripper\WObj:=wobj_vision;
	MoveAbsJ HomeTarget_Mirror,v1000,z100,TCP_RobotGripper\WObj:=wobj_vision;
ENDPROC



ENDMODULE