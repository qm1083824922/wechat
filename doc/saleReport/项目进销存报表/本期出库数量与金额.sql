select
    temp3.projectId,
    temp3.busiUnitId,
    temp3.projectName,
    temp3.businessName,
    sum(temp3.current_out_num) current_out_num,
    sum(temp3.current_out_amount) current_out_amount,
    sum(temp3.current_other_out_num) current_other_out_num,
    sum(temp3.current_other_amount) current_other_amount,
    (sum(temp3.current_out_num) + sum(temp3.current_other_out_num) ) current_num,
    (sum(temp3.current_out_amount) + sum(temp3.current_other_amount)) current_amount
from (select projectId,
             busiUnitId,
             concat(projectNo, '-', abbreviationProjectName) projectName,
             concat(subjectNo, '-', abbreviation)            businessName,
             IFNULL(SUM(temp1.send_num), 0)                  current_out_num,
             IFNULL(SUM(temp1.cost_amount), 0)               current_out_amount,
             0 current_other_out_num,
             0 current_other_amount
      from (SELECT DISTINCT tbos.id,
                            tbos.project_id      projectId,
                            tbp.project_no       projectNo,
                            tbp.project_name     abbreviationProjectName,
                            tbs.subject_no       subjectNo,
                            tbs.abbreviation     abbreviation,
                            tbp.business_unit_id busiUnitId,
                            tbos.send_num,
                            tbos.cost_amount
            from tb_bill_out_store tbos
                     left join tb_bill_out_store_dtl tbosd on tbos.id = tbosd.bill_out_store_id
                     left join tb_bill_delivery tbd on tbd.id = tbos.bill_delivery_id
                     left join tb_base_goods tbg on tbosd.goods_id = tbg.id
                     inner join tb_base_user_project bup on tbos.project_id = bup.project_id
                     inner join tb_base_project tbp on tbp.id = bup.project_id
                     INNER JOIN tb_base_subject tbs ON tbp.business_unit_id = tbs.id
            where 1 = 1
              and tbos.is_delete = 0
              AND bup.user_id = 1
              AND bup.state = 1
              AND (tbs.subject_type & 1 = 1)
              and (tbos.bill_type = 1 or tbos.bill_type = 5)
              AND tbos.send_date >= '2019-12-01 00:00:00'
              AND tbos.send_date <= '2019-12-12 00:00:00'
              AND tbos.status = 5
           ) temp1
      group by projectId
     union
     select projectId,
             busiUnitId,
             concat(projectNo, '-', abbreviationProjectName) projectName,
             concat(subjectNo, '-', abbreviation)            businessName,
             0 current_out_num,
             0 current_out_amount,
             IFNULL(SUM(temp1.send_num), 0)                  current_other_out_num,
             IFNULL(SUM(temp1.cost_amount), 0)               current_other_amount
      from (SELECT DISTINCT tbos.id,
                            tbos.project_id      projectId,
                            tbp.project_no       projectNo,
                            tbp.project_name     abbreviationProjectName,
                            tbs.subject_no       subjectNo,
                            tbs.abbreviation     abbreviation,
                            tbp.business_unit_id busiUnitId,
                            tbos.send_num,
                            tbos.cost_amount
            from tb_bill_out_store tbos
                     left join tb_bill_out_store_dtl tbosd on tbos.id = tbosd.bill_out_store_id
                     left join tb_bill_delivery tbd on tbd.id = tbos.bill_delivery_id
                     left join tb_base_goods tbg on tbosd.goods_id = tbg.id
                     inner join tb_base_user_project bup on tbos.project_id = bup.project_id
                     inner join tb_base_project tbp on tbp.id = bup.project_id
                     INNER JOIN tb_base_subject tbs ON tbp.business_unit_id = tbs.id
            where 1 = 1
              and tbos.is_delete = 0
              AND bup.user_id = 1
              AND bup.state = 1
              AND (tbs.subject_type & 1 = 1)
              and (tbos.bill_type = 2 or tbos.bill_type = 3 or tbos.bill_type = 4 or tbos.bill_type = 6 or
                   tbos.bill_type = 7 or tbos.bill_type = 8)
              AND tbos.send_date >= '2019-12-01 00:00:00'
              AND tbos.send_date <= '2019-12-12 00:00:00'
              AND tbos.status = 5
           ) temp1
      group by projectId
     ) temp3 group by projectId,busiUnitId
