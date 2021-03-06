package com.wx.cp.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

@Getter
@Setter
@ToString
public class AuditRequestVO {

    private Integer id;
    /** 状态 */
    private Integer state;
    /** 项目ID */
    private Integer projectId;
    private String projectName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime auditorPassAt;

    /** 供应商ID */
    private Integer supplierId;
    /** 客户ID */
    private Integer customerId;
    /** 订单类型 */
    private Integer poId;
    /** 订单类型 */
    private Integer poType;
    /** 单据编号 */
    private String poNo;
    /** 当前审核人ID */
    private Integer auditorId;
    /** 申请人ID */
    private Integer proposerId;
    /** 币种 **/
    private Integer currencyId;
    private String openid;
}
