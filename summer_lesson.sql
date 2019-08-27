select 
aa.user_number,
aa.s_subject,
aa.lesson_begin_day,
aa.lesson_rank,
aa.duration,
aa.class_second,
aa.duration_rate
from

(-- 暑期课课节记录
SELECT 
-- 外键, 用于关联order_info
a.course_number,
a.class_number,
case when b.subject in (2,20) then '数学' when b.subject in (1,10) then '语文'  else '英语' end as s_subject,
a.mini_class_number,
a.user_number,

-- 课节信息
a.course_lesson_number,
-- 课节的顺序
row_number() over(partition by a.user_number,a.course_number,a.class_number,a.mini_class_number order by a.begin_day) as lesson_rank,
-- lesson 开始日期、时间
a.begin_day as lesson_begin_day,
a.begin_time as lesson_being_time, 
a.begin_time ,
a.end_time,
a.duration,
extract(epoch FROM (a.end_time-a.begin_time)) as class_second,
a.duration/extract(epoch FROM (a.end_time-a.begin_time)) as duration_rate,
-- 用户上课状态
-- 用户是否出勤
case when a.user_attend_status = 1 then 1 else 0 end as is_attend,
-- 用户是否出勤（包括回看）
case when a.user_attend_status = 1 then 1 
     when a.is_playback = 1 then 1 else 0 end as att_all,
-- 用户是否完课
a.is_complete_lesson,
-- 用户是否观看回看
a.is_playback,
-- 用户是提交作业
y.is_submit,
-- 辅导教师教师是否批改
y.is_correction,
-- 用户是否订正
y.is_emend
-- 用户课节情况
from o_bkxt_student_mini_class_lesson_record a

  -- 课程信息
  join o_bkxt_course b on a.course_number = b.course_number
  -- 大班信息
  join o_bkxt_class c on a.class_number = c.class_number
  -- 小班信息
  join o_bkxt_mini_class d on d.mini_class_number = a.mini_class_number
  -- 获取作业信息
  left join 
  (select  --- 作业提交
  class_number,
  mini_class_number,
  course_lesson_number,
  user_number,
  homework_id,
  submit_time,
  sum(case when status > 1 then 1 else 0 end) as is_submit,
  sum(case when status > 2 then 1 else 0 end) as is_correction,
  sum(case when status > 3 then 1 else 0 end) as is_emend
  from
  o_bkxt_homeworkanswer
  where is_del = 0 
  group by 1,2,3,4,5,6)y
  on a.class_number = y.class_number 	
  and a.mini_class_number = y.mini_class_number 
  and a.user_number = y.user_number
  and a.course_lesson_number = y.course_lesson_number
  
-- 限制 i 期课节
where c.start_day in ('2019-07-01','2019-07-13','2019-07-26','2019-08-08')
-- 限制暑期正价课
and b.term = 6
and b.category = 2
-- 剔除测试数据
and b.title not like '%测试%'
and c.class_name not like '%测试%'
and c.is_del = 0
and c.start_day >= '2019-07-01'
)aa
limit 10