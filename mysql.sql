USE `sxw_score`;
DROP procedure IF EXISTS `T_Score_test`;

DELIMITER $$
USE `sxw_score`$$
CREATE DEFINER=`db_zp`@`%`  PROCEDURE `T_Score_test`(s_Name VARCHAR(100))
PROC:BEGIN

	CREATE TEMPORARY TABLE IF NOT EXISTS tmp_corseName (t_examName VARCHAR(100),t_coreseName VARCHAR(200),t_coreseID int); #定义临时表，获取到考试对应科目   
	CREATE TEMPORARY TABLE IF NOT EXISTS tmp_Point (id int, pid int ,t_examName VARCHAR(100),t_coursename VARCHAR (100),t_questionNo varchar(10),t_questionPoint INT,t_questionType INT); #获取对应科目下的小题得分
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_Col (id int, pid int ,t_TableName VARCHAR(100),t_coursename VARCHAR (100),t_questionNo varchar(10),t_questionPoint INT,t_questionType INT); #获取对应科目下的小题得分
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_Q2 (id int, pid int ,t_TableName VARCHAR(100),t_coursename VARCHAR (100),t_questionNo varchar(10),t_questionPoint INT,t_questionType INT); #获取对应科目下的小题得分
    CREATE TEMPORARY TABLE  IF Not EXISTS  tmp_school (school_ID INT,school_Name varchar(100));
	CREATE TEMPORARY TABLE  IF Not EXISTS  tmp_class (orgid INT,className varchar(100));
	CREATE TEMPORARY TABLE  IF Not EXISTS  tmp_sutudent (ID INT auto_increment primary key ,s_ScoreNumber varchar(50),s_studentName varchar(50));


/*首先通过传入的考试名称判断是否存在该考试*/
	IF NOT EXISTS(SELECT 1 FROM sxw_score.score_exams where sxw_score.score_exams.name = s_Name ) 
		AND NOT EXISTS(SELECT 1 FROM sxw_score.s_score_exams where sxw_score.s_score_exams.name = s_Name ) 
        AND NOT EXISTS(SELECT 1 FROM sxw_score_county.score_exams where sxw_score_county.score_exams.name = s_Name ) THEN
		
        SELECT "考试还没有创建，或者考试名称错误，请确认后再执行该存储过程...";
        LEAVE PROC;
        
	END IF;
    
    
	IF EXISTS( SELECT 1 FROM sxw_score.score_exams where sxw_score.score_exams.name = s_Name ) THEN 
		
		SET  @s_Type= 0 ; #表示是市级考试
		
		SELECT id INTO @exID FROM sxw_score.score_exams where sxw_score.score_exams.name = s_Name;
       
		INSERT INTO tmp_sutudent(s_ScoreNumber,s_studentName)  select sxw_score.score_student.examno,sxw_score.score_student.name from sxw_score.score_student where examid=@exID ;   
       
       	INSERT INTO tmp_corseName select sxw_score.score_exams.name,sxw_score.Score_Exams_Courses.coursename,sxw_score.Score_Exams_Courses.id
		from sxw_score.score_exams inner join sxw_score.Score_Exams_Courses on sxw_score.score_exams.id = sxw_score.Score_Exams_Courses.examid
		where sxw_score.score_exams.name =s_Name;
    
		INSERT INTO tmp_Point select sxw_score.score_papers_questions.id,sxw_score.score_papers_questions.pid,sxw_score.score_exams.name,sxw_score.score_exams_courses.coursename,sxw_score.score_papers_questions.questionno,
		sxw_score.score_papers_questions.point,sxw_score.score_papers_questions.catagory
		from sxw_score.score_papers_questions inner join sxw_score.score_exams_courses 
		on sxw_score.score_papers_questions.courseid = sxw_score.score_exams_courses.id inner join sxw_score.score_exams 
		on sxw_score.score_exams_courses.examid = sxw_score.score_exams .id
		where sxw_score.score_exams.name =s_Name; 
    
    
		INSERT INTO tmp_Col select  sxw_score.score_papers_questions.id,sxw_score.score_papers_questions.pid, sxw_score.score_exams.name,sxw_score.score_exams_courses.coursename,sxw_score.score_papers_questions.questionno,
		sxw_score.score_papers_questions.point,sxw_score.score_papers_questions.catagory
		from sxw_score.score_papers_questions inner join sxw_score.score_exams_courses 
		on sxw_score.score_papers_questions.courseid = sxw_score.score_exams_courses.id inner join sxw_score.score_exams 
		on sxw_score.score_exams_courses.examid = sxw_score.score_exams .id
		where sxw_score.score_exams.name =s_Name; 
    
		INSERT INTO tmp_Q2 select  sxw_score.score_papers_questions.id,sxw_score.score_papers_questions.pid, sxw_score.score_exams.name,sxw_score.score_exams_courses.coursename,sxw_score.score_papers_questions.questionno,
		sxw_score.score_papers_questions.point,sxw_score.score_papers_questions.catagory
		from sxw_score.score_papers_questions inner join sxw_score.score_exams_courses 
		on sxw_score.score_papers_questions.courseid = sxw_score.score_exams_courses.id inner join sxw_score.score_exams 
		on sxw_score.score_exams_courses.examid = sxw_score.score_exams .id
		where sxw_score.score_exams.name =s_Name;
 
        
		ELSEIF EXISTS (SELECT 1 FROM sxw_score.s_score_exams where sxw_score.s_score_exams.name = s_Name ) THEN
		
			SET @s_Type = 1 ; #表示是校级考试
        
			SELECT id INTO @exID FROM sxw_score.s_score_exams where sxw_score.s_score_exams.name = s_Name;
        
			INSERT INTO tmp_sutudent(s_ScoreNumber,s_studentName)  select sxw_score.s_score_student.examno,sxw_score.s_score_student.name from sxw_score.s_score_student where examid=@exID ;  
            
            INSERT INTO tmp_corseName select sxw_score.s_score_exams.name,sxw_score.s_Score_Exams_Courses.coursename,sxw_score.s_Score_Exams_Courses.id
			from sxw_score.s_score_exams inner join sxw_score.s_Score_Exams_Courses on sxw_score.s_score_exams.id = sxw_score.s_Score_Exams_Courses.examid
			where sxw_score.s_score_exams.name =s_Name;
    
			INSERT INTO tmp_Point select sxw_score.s_score_papers_questions.id,sxw_score.s_score_papers_questions.pid, sxw_score.s_score_exams.name,sxw_score.s_score_exams_courses.coursename,sxw_score.s_score_papers_questions.questionno,
			sxw_score.s_score_papers_questions.point,sxw_score.s_score_papers_questions.catagory
			from sxw_score.s_score_papers_questions inner join sxw_score.s_score_exams_courses 
			on sxw_score.s_score_papers_questions.courseid = sxw_score.s_score_exams_courses.id inner join sxw_score.s_score_exams 
			on sxw_score.s_score_exams_courses.examid = sxw_score.s_score_exams .id
			where sxw_score.s_score_exams.name =s_Name; 
    
    
			INSERT INTO tmp_Col select sxw_score.s_score_papers_questions.id,sxw_score.s_score_papers_questions.pid,  sxw_score.s_score_exams.name,sxw_score.s_score_exams_courses.coursename,sxw_score.s_score_papers_questions.questionno,
			sxw_score.s_score_papers_questions.point,sxw_score.s_score_papers_questions.catagory
			from sxw_score.s_score_papers_questions inner join sxw_score.s_score_exams_courses 
			on sxw_score.s_score_papers_questions.courseid = sxw_score.s_score_exams_courses.id inner join sxw_score.s_score_exams 
			on sxw_score.s_score_exams_courses.examid = sxw_score.s_score_exams .id
			where sxw_score.s_score_exams.name =s_Name; 
    
    
			INSERT INTO tmp_Q2 select sxw_score.s_score_papers_questions.id,sxw_score.s_score_papers_questions.pid,  sxw_score.s_score_exams.name,sxw_score.s_score_exams_courses.coursename,sxw_score.s_score_papers_questions.questionno,
			sxw_score.s_score_papers_questions.point,sxw_score.s_score_papers_questions.catagory
			from sxw_score.s_score_papers_questions inner join sxw_score.s_score_exams_courses 
			on sxw_score.s_score_papers_questions.courseid = sxw_score.s_score_exams_courses.id inner join sxw_score.s_score_exams 
			on sxw_score.s_score_exams_courses.examid = sxw_score.s_score_exams .id
			where sxw_score.s_score_exams.name =s_Name; 
 
    
			ELSEIF EXISTS( SELECT 1 FROM sxw_score_county.score_exams where sxw_score_county.score_exams.name = s_Name ) THEN 
		
				SET @s_Type = 2 ; #表示是区县级考试
                
        
				SELECT id INTO @exID FROM sxw_score_county.score_exams where sxw_score_county.score_exams.name = s_Name;
        
				INSERT INTO tmp_sutudent(s_ScoreNumber,s_studentName)  select sxw_score_county.score_student.examno,sxw_score_county.score_student.name from sxw_score_county.score_student where examid=@exID ;   
                
                       	INSERT INTO tmp_corseName select sxw_score_county.score_exams.name,sxw_score_county.Score_Exams_Courses.coursename,sxw_score_county.Score_Exams_Courses.id
						from sxw_score_county.score_exams inner join sxw_score_county.Score_Exams_Courses on sxw_score_county.score_exams.id = sxw_score_county.Score_Exams_Courses.examid
						where sxw_score_county.score_exams.name =s_Name;
    
						INSERT INTO tmp_Point select sxw_score_county.score_papers_questions.id,sxw_score_county.score_papers_questions.pid, sxw_score_county.score_exams.name,sxw_score_county.score_exams_courses.coursename,sxw_score_county.score_papers_questions.questionno,
						sxw_score_county.score_papers_questions.points,sxw_score_county.score_papers_questions.catagory
						from sxw_score_county.score_papers_questions inner join sxw_score_county.score_exams_courses 
						on sxw_score_county.score_papers_questions.courseid = sxw_score_county.score_exams_courses.id inner join sxw_score_county.score_exams 
						on sxw_score_county.score_exams_courses.examid = sxw_score_county.score_exams .id
						where sxw_score_county.score_exams.name =s_Name; 
    
    
						INSERT INTO tmp_Col  select sxw_score_county.score_papers_questions.id,sxw_score_county.score_papers_questions.pid,  sxw_score_county.score_exams.name,sxw_score_county.score_exams_courses.coursename,sxw_score_county.score_papers_questions.questionno,
						sxw_score_county.score_papers_questions.points,sxw_score_county.score_papers_questions.catagory
						from sxw_score_county.score_papers_questions inner join sxw_score_county.score_exams_courses 
						on sxw_score_county.score_papers_questions.courseid = sxw_score_county.score_exams_courses.id inner join sxw_score_county.score_exams 
						on sxw_score_county.score_exams_courses.examid = sxw_score_county.score_exams .id
						where sxw_score_county.score_exams.name =s_Name; 
    
						INSERT INTO tmp_Q2  select sxw_score_county.score_papers_questions.id,sxw_score_county.score_papers_questions.pid,  sxw_score_county.score_exams.name,sxw_score_county.score_exams_courses.coursename,sxw_score_county.score_papers_questions.questionno,
						sxw_score_county.score_papers_questions.points,sxw_score_county.score_papers_questions.catagory
						from sxw_score_county.score_papers_questions inner join sxw_score_county.score_exams_courses 
						on sxw_score_county.score_papers_questions.courseid = sxw_score_county.score_exams_courses.id inner join sxw_score_county.score_exams 
						on sxw_score_county.score_exams_courses.examid = sxw_score_county.score_exams .id
						where sxw_score_county.score_exams.name =s_Name; 
    
    ELSE 
		IF NOT EXISTS(SELECT 1 FROM tmp_sutudent ) THEN 
    
			SELECT "对应考试还没有导入准考证，请导入学生准考证号后，在执行该存储过程......";
        
			LEAVE PROC;
		END IF;
    
    END IF;
    
    ####开始查询学生数据到临时表
    
        
	SELECT count(1) INTO @tempCount FROM tmp_sutudent  ;
    
    SET @new_tempCount = 1;
    
    #SET @DebugCount = 10 ;# 调试用，表示要生成10个考生的成绩数据 
    
    
    #开始根据考试科目生成对应的成绩数据临时表
    
    select count(1) INTO @count_corse FROM tmp_corseName;
    
    WHILE  @count_corse > 0 DO
    
		SELECT t_coreseName INTO @Corese_name From tmp_corseName  limit 1 ;
        
        SET @new_coreseName = concat('Tmp_',@Corese_name);
        
		#定义动态生成临时表的语句
        
        SET @Create_table = concat('CREATE TEMPORARY TABLE IF NOT EXISTS',' `',@new_coreseName,'`',' (ID INT auto_increment primary key , CourseName varchar(50),ScoreNo varchar(100),
        StudentName varchar(50) ,选择题成绩 varchar(300),选择题答案 varchar(300))');
        
        PREPARE T_SQL_CreateTable FROM @Create_table  ; 
        
        EXECUTE T_SQL_CreateTable;
        
        
        
        #SET @tempCount  = 100 ;
        
        SELECT count(1) INTO @Count_qustion_2 FROM tmp_Q2 WHERE t_coursename = @Corese_name and t_questionType =1 ;
        
        WHILE @tempCount > 0 DO
        
			#SET @Insert_default = concat('insert into ','`',@new_coreseName,'`',' values (','\'',@Corese_name,'\'',',1,1,1,1)');
            
            SET @Insert_default = concat('insert into ','`',@new_coreseName,'`',' (CourseName,ScoreNo,StudentName,选择题成绩,选择题答案)  SELECT ','\'',@Corese_name,'\'',
            ' ,s_ScoreNumber , s_studentName,1,1 from tmp_sutudent where ID = ',@new_tempCount);
        
			PREPARE T_SQL_Insert_Default FROM @Insert_default  ; 
        
			EXECUTE T_SQL_Insert_Default;  
            
            #INSERT INTO tmp_debug (s_Sql) values (@Insert_default);
            
			
            SET @Q2_score = rand_string(@Count_qustion_2,'04');
        
			SET @Q2_Answer = rand_string(@Count_qustion_2,'ABCD');
        
			SET @Update_Q2 = concat('UPDATE ','`',@new_coreseName,'`',' SET 选择题答案 = ','\'',@Q2_Answer,'\'',', 选择题成绩 =','\'',@Q2_score,'\'',' WHERE ID = ',@new_tempCount);
        

        
			PREPARE T_SQL_UPDATE_Q2  FROM @Update_Q2;
        
			EXECUTE T_SQL_UPDATE_Q2;
            
            #SELECT  @Update_Q2;
            
            SET @new_tempCount =@new_tempCount +1 ;
        
			SET  @tempCount =  @tempCount -1 ;
        
        END WHILE ;
        ####学生数据插入结束
        SELECT count(1) INTO @tempCount FROM tmp_sutudent  ;
        SET @new_tempCount = 1 ;
        ##开始根据每个科目的主观题目数动态追加临时表的列
        
        SELECT count(1) INTO @Count_qustion_02 FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2 AND pid is NULL ; #获取非选择题的大题个数
        
        WHILE @Count_qustion_02 > 0 DO
        
			SELECT  id INTO @id FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ; #拿到大题的ID作为小题的PID进行查询
            
			SELECT count(1) INTO @Count_qustion_02_S FROM tmp_Point WHERE t_coursename = @Corese_name and pid=@id ; #获取到对应大题下面是否有小题
            
            IF @Count_qustion_02_S = 0 THEN  ###如果@Count_qustion_02_S=0.则表示大题下面没有小题.
            
				SELECT  t_questionNo INTO @Score_Title FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;
            
				#SELECT  ID INTO @p_id FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ; ##现获取到大题号对应的ID
            
				set @addcol =  concat('alter table ','`',@new_coreseName,'`',' add ','`','T',@Score_Title,'`',' varchar(100)');
                


				PREPARE T_SQL_Add FROM @addcol;
        
				EXECUTE T_SQL_Add;     
			
            ELSE ##如果@Count_qustion_02_S>0.则表示大题下面还有小题，则动态生成列的时候，需要考虑列头的命名
				
                WHILE @Count_qustion_02_S>0 DO 
                
					SELECT  t_questionNo INTO @Score_Title_b FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;
                    
                    SELECT  id INTO @pp_ID FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;
                
					SELECT  t_questionNo INTO @Score_Title_s FROM tmp_Point WHERE t_coursename = @Corese_name and t_questionType =2  AND pid =@pp_ID limit 1 ; ##现获对应的小题号
                    
                    SET @New_Score_Title = concat(@Score_Title_b,'.',@Score_Title_s);
                    
                    SET @addcol =  concat('alter table ','`',@new_coreseName,'`',' add ','`','T',@New_Score_Title,'`',' varchar(100)');
                    
                    #SELECT @addcol;

					PREPARE T_SQL_Add FROM @addcol;
        
					EXECUTE T_SQL_Add; 
                    
					DELETE FROM tmp_Point WHERE  t_coursename = @Corese_name and t_questionType =2 AND pid =@pp_ID  limit 1;
                    
                    SET @Count_qustion_02_S = @Count_qustion_02_S -1 ;
                    
                END WHILE;
                
			
            END IF;

			SET @Count_qustion_02 = @Count_qustion_02 -1 ;
            
			DELETE FROM tmp_Point WHERE  t_coursename = @Corese_name and t_questionType =2 AND pid is NULL  limit 1;
            
        END WHILE ;
        
        ####开始随机生成主观题得分
        
		SELECT count(1) INTO @Count_qustion_02_bak FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2 AND pid is NULL ; #获取非选择题的大题个数 ;
        
        WHILE @Count_qustion_02_bak > 0 DO
        
			SELECT  id INTO @c_id FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ; #拿到大题的ID作为小题的PID进行查询
            
			SELECT count(1) INTO @c_Count_qustion_02_S FROM tmp_Col WHERE t_coursename = @Corese_name and pid=@c_id ; #获取到对应大题下面是否有小题
            
            IF @c_Count_qustion_02_S = 0 THEN  ###如果@Count_qustion_02_S=0.则表示大题下面没有小题.
        
				SELECT  t_questionNo INTO @Score_Title_bak FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;
				

				SET @Update_Score = concat('UPDATE ','`',@new_coreseName,'`',' SET T',@Score_Title_bak,' = (SELECT FLOOR(0 + (RAND() * (t_questionPoint+1)))  FROM tmp_Col WHERE t_coursename =','\'',@Corese_name,'\'',
				'  AND t_questionType =2 AND t_questionNo = ','\'',@Score_Title_bak ,'\'',' limit 1)' ,' where 1= 1');

				PREPARE T_SQL_Update FROM @Update_Score;
                
				EXECUTE T_SQL_Update;
                
                #select * from `Tmp_语文(文)`;
                
			ELSE  ## 有小题的话
				 WHILE @c_Count_qustion_02_S>0 DO 
					
					SELECT  t_questionNo INTO @c_Score_Title_b FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;#获取大题题号
                    
                    SELECT  id INTO @c_pp_ID FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND pid is NULL limit 1 ;#获取大题ID
                
					SELECT  t_questionNo INTO @c_Score_Title_s FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND pid =@c_pp_ID limit 1; ##现获对应的小题号
                    
                    SELECT  id INTO @cc_id FROM tmp_Col WHERE t_coursename = @Corese_name and t_questionType =2  AND t_questionNo =@c_Score_Title_s limit 1 ; ##现获对应的ID
                    
                    
                    SET @c_New_Score_Title = concat(@c_Score_Title_b,'.',@c_Score_Title_s);
                    
					SET @Update_Score = concat('UPDATE ','`',@new_coreseName,'`',' SET ','`','T',@c_New_Score_Title,'`',' = (SELECT FLOOR(0 + (RAND() * (t_questionPoint+1)))  FROM tmp_Col WHERE t_coursename =','\'',@Corese_name,'\'',
					'  AND t_questionType =2 AND id = ',@cc_id,')' ,' where 1= 1');
                    
                    #SELECT @Update_Score;

					PREPARE T_SQL_Update FROM @Update_Score;
                
					EXECUTE T_SQL_Update;
                    
					
                    DELETE FROM tmp_Col WHERE  t_coursename = @Corese_name and t_questionType =2 and pid = @c_pp_ID limit 1 ;
                    
                    
                    SET @c_Count_qustion_02_S = @c_Count_qustion_02_S -1 ;
					
                 
                 END WHILE;
              
			END IF;
        
			SET @Count_qustion_02_bak = @Count_qustion_02_bak - 1;
            
            DELETE FROM tmp_Col WHERE  t_coursename = @Corese_name and t_questionType =2 AND pid is NULL  limit 1;
		
        
        END WHILE;
         
		####主观题得分生成完成
        
        SET @DebugSql = concat('SELECT * from ' ,'`',@new_coreseName,'`');
        
        PREPARE T_SQL_DEBUG FROM @DebugSql;
        
        EXECUTE T_SQL_DEBUG;
        
        
        #####删除临时表，防止SP执行错误时，提示临时表存在
        
		set @dorp_Sql = concat('Drop TABLE ','`',@new_coreseName,'`');
        
        PREPARE t_dropSql FROM @dorp_Sql ;
        
        EXECUTE t_dropSql;
        
        #####
        
        SET @count_corse = @count_corse - 1 ;
        
        DELETE FROM tmp_corseName WHERE 1=1 limit 1;
    
    END WHILE ;
    
    #select * from tmp_sutudent;
    
    DROP TABLE tmp_corseName;
    DROP TABLE tmp_Point;
    DROP TABLE tmp_Col;
    DROP TABLE tmp_Q2;
	DROP TABLE tmp_sutudent;
    DROP TABLE tmp_school;
    DROP TABLE tmp_class;

END $$

DELIMITER ;

use sxw_score;

 call T_Score_test('0720绵阳市高2014级分科考试');
