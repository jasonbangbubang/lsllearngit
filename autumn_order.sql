select 
a.bkxt_user_number,
case when b.subject in (2,20) then  '数学' when b.subject in (1,10 ) then '语文'  else '英语' end as s_subject,
count(1) as num,
sum(pay_amount)*1.0/100 as pay
from o_bkxt_order_info a
join o_bkxt_course b on a.course_number = b.course_number
join o_bkxt_class c on a.class_number = c.class_number
where  a.order_status in (2,5)
and a.pay_amount > a.refund_amount 
and b.term = 3
and b.category = 2
and a.day >= '2019-07-01'
and a.day <= '2019-08-25'
and c.start_day between  '2019-09-02' and '2019-09-20'
group by 1,2
