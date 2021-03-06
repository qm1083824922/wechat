select projectId,
       busiUnitId,
       projectName,
       businessName                                                           businessUnitName,
       goodsId,
       brand,
       goodName,
       goodsType,
       specification,
       number,
       taxRate,
       barCode,
       sum(initial_in_num)                                                    initial_in_num,
       sum(initial_in_amount)                                                 initial_in_amount,
       sum(initial_end_num)                                                   initial_end_num,
       sum(initial_end_amount)                                                initial_end_amount,
       sum(initial_num)                                                       initial_num,
       sum(initial_amount)                                                    initial_amount,
       sum(current_normal_in_num)                                             current_normal_in_num,
       sum(current_normal_in_amount)                                          current_normal_in_amount,
       sum(current_other_in_num)                                              current_other_in_num,
       sum(current_other_in_amount)                                           current_other_in_amount,
       sum(current_in_num)                                                    current_in_num,
       sum(current_in_amount)                                                 current_in_amount,
       sum(current_normal_out_num)                                            current_normal_out_num,
       sum(current_normal_out_amount)                                         current_normal_out_amount,
       sum(current_other_out_num)                                             current_other_out_num,
       sum(current_other_out_amount)                                          current_other_out_amount,
       sum(current_out_num)                                                   current_out_num,
       sum(current_out_amount)                                                current_out_amount,
       sum(initial_num) + sum(current_in_num) - sum(current_out_num)          end_num,
       sum(initial_amount) + sum(current_in_amount) - sum(current_out_amount) end_amount,
       IFNULL(DATEDIFF(DATE_FORMAT('2019-12-16', "%Y-%m-%d"), DATE_FORMAT('2019-12-01', "%Y-%m-%d")) * 0.5 *
              (sum(initial_num) + (sum(initial_num) + sum(current_in_num) - sum(current_out_num))) /
              sum(current_normal_out_num), 0)                                 inventory_turnover_days,
       IFNULL(360 / (DATEDIFF(DATE_FORMAT('2019-12-16', "%Y-%m-%d"), DATE_FORMAT('2019-12-01', "%Y-%m-%d")) * 0.5 *
                     (sum(initial_num) + (sum(initial_num) + sum(current_in_num) - sum(current_out_num))) /
                     sum(current_normal_out_num)), 0)                         inventory_turnover
from (select temp3.projectId,
             temp3.busiUnitId,
             temp3.projectName,
             temp3.businessName,
             goodsId,
             brand,
             goodName,
             goodsType,
             specification,
             number,
             taxRate,
             barCode,
             sum(temp3.initial_in_num)                                      initial_in_num,
             sum(temp3.initial_in_amount)                                   initial_in_amount,
             sum(temp3.initial_end_num)                                     initial_end_num,
             sum(temp3.initial_end_amount)                                  initial_end_amount,
             (sum(temp3.initial_in_num) - sum(temp3.initial_end_num))       initial_num,
             (sum(temp3.initial_in_amount) - sum(temp3.initial_end_amount)) initial_amount,
             0                                                              current_normal_in_num,
             0                                                              current_normal_in_amount,
             0                                                              current_other_in_num,
             0                                                              current_other_in_amount,
             0                                                              current_in_num,
             0                                                              current_in_amount,
             0                                                              current_normal_out_num,
             0                                                              current_normal_out_amount,
             0                                                              current_other_out_num,
             0                                                              current_other_out_amount,
             0                                                              current_out_num,
             0                                                              current_out_amount
      from (SELECT projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   IFNULL(SUM(temp.receive_num), 0)                initial_in_num,
                   IFNULL(SUM(temp.receive_amount), 0)             initial_in_amount,
                   0                                               initial_end_num,
                   0                                               initial_end_amount,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode
            FROM (SELECT tbis.project_id                           projectId,
                         tbp.project_no                            projectNo,
                         tbp.project_name                          abbreviationProjectName,
                         tbs.subject_no                            subjectNo,
                         tbs.abbreviation                          abbreviation,
                         tbp.business_unit_id                      busiUnitId,
                         tbisd.goods_id                            goodsId,
                         tbg.brand                                 brand,
                         tbg.name                                  goodName,
                         tbg.goods_type                            goodsType,
                         tbisd.receive_num,
                         (tbisd.receive_num * tbisd.receive_price) receive_amount,
                         tbg.specification                         specification,
                         tbg.number                                number,
                         tbg.tax_rate                              taxRate,
                         tbg.bar_code                              barCode
                  FROM tb_bill_in_store tbis
                           INNER JOIN tb_bill_in_store_dtl tbisd ON tbis.id = tbisd.bill_in_store_id
                           INNER JOIN tb_base_goods tbg ON tbisd.goods_id = tbg.id
                           INNER JOIN tb_base_user_project bup ON tbis.project_id = bup.project_id
                           INNER JOIN tb_base_project tbp ON tbp.id = bup.project_id
                           INNER JOIN tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  WHERE 1 = 1
                    AND tbis.is_delete = 0
                    and bup.user_id = ?
                    and bup.state = 1
                    AND tbis.STATUS = 2
                    AND (tbs.subject_type & 1 = 1)
                    and DATE_FORMAT(tbis.receive_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp
            group by projectId, busiUnitId, goodsId
            union
            SELECT projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   0                                               initial_in_num,
                   0                                               initial_in_amount,
                   IFNULL(SUM(temp2.send_num), 0)                  initial_end_num,
                   IFNULL(SUM(temp2.send_amount), 0)               initial_end_amount,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode
            FROM (SELECT tbos.project_id      projectId,
                         tbp.project_no       projectNo,
                         tbp.project_name     abbreviationProjectName,
                         tbs.subject_no       subjectNo,
                         tbs.abbreviation     abbreviation,
                         tbp.business_unit_id busiUnitId,
                         tbosd.send_num,
                         tbosd.cost_amount    send_amount,
                         tbosd.goods_id       goodsId,
                         tbg.brand            brand,
                         tbg.name             goodName,
                         tbg.goods_type       goodsType,
                         tbg.specification    specification,
                         tbg.number           number,
                         tbg.tax_rate         taxRate,
                         tbg.bar_code         barCode
                  FROM tb_bill_out_store tbos
                           INNER JOIN tb_bill_out_store_dtl tbosd ON tbos.id = tbosd.bill_out_store_id
                           INNER JOIN tb_bill_delivery tbd ON tbd.id = tbos.bill_delivery_id
                           INNER JOIN tb_base_goods tbg ON tbosd.goods_id = tbg.id
                           INNER JOIN tb_base_user_project bup ON tbos.project_id = bup.project_id
                           INNER JOIN tb_base_project tbp ON tbp.id = bup.project_id
                           INNER JOIN tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  WHERE 1 = 1
                    AND tbos.is_delete = 0
                    and bup.user_id = 1
                    and bup.state = 1
                    AND tbos.STATUS = 5
                    AND (tbs.subject_type & 1 = 1)
                    and DATE_FORMAT(tbos.send_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp2
            GROUP BY projectId, busiUnitId, goodsId) temp3
      group by projectId, busiUnitId, goodsId
      union
      select temp3.projectId,
             temp3.busiUnitId,
             temp3.projectName,
             temp3.businessName,
             goodsId,
             brand,
             goodName,
             goodsType,
             specification,
             number,
             taxRate,
             barCode,
             0                                                                          initial_in_num,
             0                                                                          initial_in_amount,
             0                                                                          initial_end_num,
             0                                                                          initial_end_amount,
             0                                                                          initial_num,
             0                                                                          initial_amount,
             sum(temp3.current_normal_in_num)                                           current_normal_in_num,
             sum(temp3.current_normal_in_amount)                                        current_normal_in_amount,
             sum(temp3.current_other_in_num)                                            current_other_in_num,
             sum(temp3.current_other_in_amount)                                         current_other_in_amount,
             (sum(temp3.current_normal_in_num) + sum(temp3.current_other_in_num))       current_in_num,
             (sum(temp3.current_normal_in_amount) + sum(temp3.current_other_in_amount)) current_in_amount,
             0                                                                          current_normal_out_num,
             0                                                                          current_normal_out_amount,
             0                                                                          current_other_out_num,
             0                                                                          current_other_out_amount,
             0                                                                          current_out_num,
             0                                                                          current_out_amount
      from (select projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode,
                   IFNULL(SUM(temp1.receive_num), 0)               current_normal_in_num,
                   IFNULL(SUM(temp1.receive_amount), 0)            current_normal_in_amount,
                   0                                               current_other_in_num,
                   0                                               current_other_in_amount
            from (select tbis.project_id                           projectId,
                         tbp.project_no                            projectNo,
                         tbp.project_name                          abbreviationProjectName,
                         tbs.subject_no                            subjectNo,
                         tbs.abbreviation                          abbreviation,
                         tbp.business_unit_id                      busiUnitId,
                         tbisd.goods_id                            goodsId,
                         tbg.brand                                 brand,
                         tbg.name                                  goodName,
                         tbg.goods_type                            goodsType,
                         tbisd.receive_num,
                         (tbisd.receive_num * tbisd.receive_price) receive_amount,
                         tbg.specification                         specification,
                         tbg.number                                number,
                         tbg.tax_rate                              taxRate,
                         tbg.bar_code                              barCode
                  from tb_bill_in_store tbis
                           inner join tb_bill_in_store_dtl tbisd on tbis.id = tbisd.bill_in_store_id
                           inner join tb_base_goods tbg on tbisd.goods_id = tbg.id
                           inner join tb_base_user_project bup on tbis.project_id = bup.project_id
                           inner join tb_base_project tbp on tbp.id = bup.project_id
                           inner join tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  where 1 = 1
                    and tbis.is_delete = 0
                    and bup.user_id = 1
                    and bup.state = 1
                    AND (tbs.subject_type & 1 = 1)
                    and (tbis.bill_type = 1 or tbis.bill_type = 3)
                    AND tbis.status = 2
                    and DATE_FORMAT(tbis.receive_date, "%Y-%m-%d") >= '2019-12-01'
                    and DATE_FORMAT(tbis.receive_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp1
            group by projectId, busiUnitId, goodsId
            union
            select projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode,
                   0                                               current_normal_in_num,
                   0                                               current_normal_in_amount,
                   IFNULL(SUM(temp2.receive_num), 0)               current_other_in_num,
                   IFNULL(SUM(temp2.receive_amount), 0)            current_other_in_amount
            from (select tbis.project_id                           projectId,
                         tbp.project_no                            projectNo,
                         tbp.project_name                          abbreviationProjectName,
                         tbs.subject_no                            subjectNo,
                         tbs.abbreviation                          abbreviation,
                         tbp.business_unit_id                      busiUnitId,
                         tbisd.goods_id                            goodsId,
                         tbg.brand                                 brand,
                         tbg.name                                  goodName,
                         tbg.goods_type                            goodsType,
                         tbisd.receive_num                         receive_num,
                         (tbisd.receive_num * tbisd.receive_price) receive_amount,
                         tbg.specification                         specification,
                         tbg.number                                number,
                         tbg.tax_rate                              taxRate,
                         tbg.bar_code                              barCode
                  from tb_bill_in_store tbis
                           inner join tb_bill_in_store_dtl tbisd on tbis.id = tbisd.bill_in_store_id
                           inner join tb_base_goods tbg on tbisd.goods_id = tbg.id
                           inner join tb_base_user_project bup on tbis.project_id = bup.project_id
                           inner join tb_base_project tbp on tbp.id = bup.project_id
                           inner join tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  where 1 = 1
                    and tbis.is_delete = 0
                    and bup.user_id = 1
                    and bup.state = 1
                    AND (tbs.subject_type & 1 = 1)
                    and (tbis.bill_type = 2 or tbis.bill_type = 4 or tbis.bill_type = 5)
                    AND tbis.status = 2
                    and DATE_FORMAT(tbis.receive_date, "%Y-%m-%d") >= '2019-12-01'
                    and DATE_FORMAT(tbis.receive_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp2
            group by projectId, busiUnitId, goodsId) temp3
      group by projectId, busiUnitId, goodsId
      union
      select temp3.projectId,
             temp3.busiUnitId,
             temp3.projectName,
             temp3.businessName,
             goodsId,
             brand,
             goodName,
             goodsType,
             specification,
             number,
             taxRate,
             barCode,
             0                                                                            initial_in_num,
             0                                                                            initial_in_amount,
             0                                                                            initial_end_num,
             0                                                                            initial_end_amount,
             0                                                                            initial_num,
             0                                                                            initial_amount,
             0                                                                            current_normal_in_num,
             0                                                                            current_normal_in_amount,
             0                                                                            current_other_in_num,
             0                                                                            current_other_in_amount,
             0                                                                            current_in_num,
             0                                                                            current_in_amount,
             sum(temp3.current_normal_out_num)                                            current_normal_out_num,
             sum(temp3.current_normal_out_amount)                                         current_normal_out_amount,
             sum(temp3.current_other_out_num)                                             current_other_out_num,
             sum(temp3.current_other_out_amount)                                          current_other_out_amount,
             (sum(temp3.current_normal_out_num) + sum(temp3.current_other_out_num))       current_out_num,
             (sum(temp3.current_normal_out_amount) + sum(temp3.current_other_out_amount)) current_out_amount
      from (select projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode,
                   IFNULL(SUM(temp1.send_num), 0)                  current_normal_out_num,
                   IFNULL(SUM(temp1.send_amount), 0)               current_normal_out_amount,
                   0                                               current_other_out_num,
                   0                                               current_other_out_amount
            from (SELECT tbos.project_id      projectId,
                         tbp.project_no       projectNo,
                         tbp.project_name     abbreviationProjectName,
                         tbs.subject_no       subjectNo,
                         tbs.abbreviation     abbreviation,
                         tbp.business_unit_id busiUnitId,
                         tbosd.send_num,
                         tbosd.cost_amount    send_amount,
                         tbosd.goods_id       goodsId,
                         tbg.brand            brand,
                         tbg.name             goodName,
                         tbg.goods_type       goodsType,
                         tbg.specification    specification,
                         tbg.number           number,
                         tbg.tax_rate         taxRate,
                         tbg.bar_code         barCode
                  from tb_bill_out_store tbos
                           inner join tb_bill_out_store_dtl tbosd on tbos.id = tbosd.bill_out_store_id
                           inner join tb_bill_delivery tbd on tbd.id = tbos.bill_delivery_id
                           inner join tb_base_goods tbg on tbosd.goods_id = tbg.id
                           inner join tb_base_user_project bup on tbos.project_id = bup.project_id
                           inner join tb_base_project tbp on tbp.id = bup.project_id
                           INNER JOIN tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  where 1 = 1
                    and tbos.is_delete = 0
                    and bup.user_id = 1
                    and bup.state = 1
                    AND (tbs.subject_type & 1 = 1)
                    and (tbos.bill_type = 1 or tbos.bill_type = 5)
                    AND tbos.status = 5
                    and DATE_FORMAT(tbos.send_date, "%Y-%m-%d") >= '2019-12-01'
                    and DATE_FORMAT(tbos.send_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp1
            group by projectId, busiUnitId, goodsId
            union
            select projectId,
                   busiUnitId,
                   concat(projectNo, '-', abbreviationProjectName) projectName,
                   concat(subjectNo, '-', abbreviation)            businessName,
                   goodsId,
                   brand,
                   goodName,
                   goodsType,
                   specification,
                   number,
                   taxRate,
                   barCode,
                   0                                               current_out_num,
                   0                                               current_out_amount,
                   IFNULL(SUM(temp1.send_num), 0)                  current_other_out_num,
                   IFNULL(SUM(temp1.send_amount), 0)               current_other_out_amount
            from (SELECT tbos.project_id      projectId,
                         tbp.project_no       projectNo,
                         tbp.project_name     abbreviationProjectName,
                         tbs.subject_no       subjectNo,
                         tbs.abbreviation     abbreviation,
                         tbp.business_unit_id busiUnitId,
                         tbosd.send_num,
                         tbosd.cost_amount    send_amount,
                         tbosd.goods_id       goodsId,
                         tbg.brand            brand,
                         tbg.name             goodName,
                         tbg.goods_type       goodsType,
                         tbg.specification    specification,
                         tbg.number           number,
                         tbg.tax_rate         taxRate,
                         tbg.bar_code         barCode
                  from tb_bill_out_store tbos
                           inner join tb_bill_out_store_dtl tbosd on tbos.id = tbosd.bill_out_store_id
                           inner join tb_bill_delivery tbd on tbd.id = tbos.bill_delivery_id
                           inner join tb_base_goods tbg on tbosd.goods_id = tbg.id
                           inner join tb_base_user_project bup on tbos.project_id = bup.project_id
                           inner join tb_base_project tbp on tbp.id = bup.project_id
                           inner join tb_base_subject tbs ON tbp.business_unit_id = tbs.id
                  where 1 = 1
                    and tbos.is_delete = 0
                    and bup.user_id = 1
                    and bup.state = 1
                    AND (tbs.subject_type & 1 = 1)
                    and (tbos.bill_type = 2 or tbos.bill_type = 3 or tbos.bill_type = 4 or tbos.bill_type = 6 or
                         tbos.bill_type = 7 or tbos.bill_type = 8)
                    AND tbos.status = 5
                    and DATE_FORMAT(tbos.send_date, "%Y-%m-%d") >= '2019-12-01'
                    and DATE_FORMAT(tbos.send_date, "%Y-%m-%d") <= '2019-12-16'
                    AND tbp.id = 10
                    -- AND tbg.number = ?
                    -- AND tbg.bar_code = ?
                ) temp1
            group by projectId, busiUnitId, goodsId) temp3
      group by projectId, busiUnitId, goodsId) temp4
where 1 = 1
  and initial_num > 0
  and initial_amount > 0
group by projectId, busiUnitId, goodsId
