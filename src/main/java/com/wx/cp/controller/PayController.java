package com.wx.cp.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.wx.cp.common.ServerResponse;
import com.wx.cp.constants.StatusConstant;
import com.wx.cp.constants.URLConstant;
import com.wx.cp.pojo.TbAudit;
import com.wx.cp.pojo.TbBaseUser;
import com.wx.cp.utils.HttpUtil;
import com.wx.cp.utils.StatusUtil;
import com.wx.cp.utils.VerifyUtil;
import com.wx.cp.utils.TokenUtil;
import com.wx.cp.vo.*;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

import static com.wx.cp.constants.StatusConstant.*;

/**
 * @author dell
 */
@RestController
@RequestMapping("/pay/")
@Slf4j
public class PayController {

    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private StringRedisTemplate redisTemplate;
    @Autowired
    private TokenUtil tokenUtil;
    @Autowired
    private HttpUtil httpUtil;
    @Autowired
    private VerifyUtil payUtil;

    /**
     * 待审核的单据
     */
    @RequestMapping(value = "waitingAuditOrder", method = {RequestMethod.GET, RequestMethod.POST})
    public ServerResponse<ResultVO<WaitingVerifyOrderVO>> waitingAuditOrder(HttpServletRequest request, PageVO pageVO) {
        try {
            String openid = tokenUtil.getToken(request);
//            String openid = "YueYi";
            log.info("openid={}", openid);
            ResultVO<WaitingVerifyOrderVO> verifyOrderVOList = new ResultVO<>();
            if (StringUtils.isNotBlank(openid)) {
                String url = URLConstant.AUDIT_QUERY;
                log.info("url={}", url);
                pageVO.setOpenid(openid);
                pageVO.setPoType(INT_5);
                pageVO.setAuditorState(INT_0);
                pageVO.setWechatFlag(true);
                log.info("pageVO={}", pageVO);
                String response = httpUtil.postByDefault(pageVO, url);
                log.info("response={}", JSONObject.parseObject(response));
                if (StringUtils.isNotBlank(response)) {
                    JSONObject responseJson = JSONObject.parseObject(response);
                    String items = responseJson.getString(URLConstant.RETURN_ITEMS);
                    log.info("items={}", JSON.parseArray(items, WaitingVerifyOrderVO.class));
                    List<WaitingVerifyOrderVO> waitingVerifyOrderVOS = JSON.parseArray(items, WaitingVerifyOrderVO.class);
                    ArrayList<WaitingVerifyOrderVO> list = new ArrayList<>();
                    for (WaitingVerifyOrderVO waitingVerifyOrderVO : waitingVerifyOrderVOS) {
                        if (INT_5 == waitingVerifyOrderVO.getPoType() || INT_1 == waitingVerifyOrderVO.getPoType()) {
                            list.add(waitingVerifyOrderVO);
                        }
                    }
                    verifyOrderVOList.setItems(list);
                    return ServerResponse.createBySuccess(verifyOrderVOList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ServerResponse.createBySuccess();

    }

    /**
     * 已审核付款单
     */
    @RequestMapping(value = "resolvedOrderList", method = {RequestMethod.GET, RequestMethod.POST})
    public ServerResponse<List<AuditResponseVO>> payOrderQuery(HttpServletRequest request) {
        try {
            String openid = tokenUtil.getToken(request);
//            String openid = "YueYi";
            if (StringUtils.isNotBlank(openid)) {
                AuditRequestVO auditRequestVO = new AuditRequestVO();
                auditRequestVO.setOpenid(openid);
                String response = httpUtil.postByDefault(auditRequestVO,URLConstant.GET_USER);
                if (StringUtils.isNotBlank(response)) {
                    TbBaseUser baseUser = JSON.parseObject(response, TbBaseUser.class);
                    auditRequestVO.setOpenid(null);
                    auditRequestVO.setAuditorId(baseUser.getId());
                    String forObject = httpUtil.postByDefault(auditRequestVO,URLConstant.PAY_RESOLVED_VERIFIED);
                    if (StringUtils.isNotBlank(forObject)) {
                        List<TbAudit> oldTbAudits = JSON.parseArray(forObject, TbAudit.class);
                        Map<Integer, TbAudit> maps = new HashMap<>();
                        List<TbAudit> newTbAudits = new ArrayList<>();
                        for (TbAudit oldTbAudit : oldTbAudits) {
                            if (maps.containsKey(oldTbAudit.getPoId())) {
                                continue;
                        }
                            maps.put(oldTbAudit.getPoId(), oldTbAudit);
                            newTbAudits.add(oldTbAudit);
                        }
                        List<AuditResponseVO> auditResponseVOList = new ArrayList<>();
                        for (TbAudit audit : newTbAudits) {
                            AuditResponseVO auditResponseVO = new AuditResponseVO();
                            BeanUtils.copyProperties(audit,auditResponseVO);
                            auditResponseVO.setPoTypeName(StatusUtil.getPoType(audit.getPoType()));
                            auditRequestVO.setAuditorId(null);
                            auditRequestVO.setId(audit.getProjectId());
                            auditResponseVO.setStateName(StatusConstant.AUDIT_STATE_100);
                            auditResponseVO.setState(StatusConstant.INT_100);
                            auditResponseVO.setProposerDate(audit.getProposerAt());
                            auditResponseVO.setProposer(audit.getProposer());
                            auditRequestVO.setAuditorPassAt(audit.getAuditorPassAt());
                            auditResponseVOList.add(auditResponseVO);
                        }
                        return ServerResponse.createBySuccess(auditResponseVOList);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ServerResponse.createBySuccess();
    }

    /**
     * 付款单据明细
     */
    @RequestMapping(value = "payOrderDetail", method = {RequestMethod.GET, RequestMethod.POST})
    public ServerResponse<PayAuditInfoVO> payOrderDetail(AuditVO auditVO) {
        try {
            String url = URLConstant.PAY_ORDER_DETAIL + auditVO.getPayId();
            log.info("url={}", url);
            String response = restTemplate.getForObject(url, String.class);
            PayAuditInfoVO payAuditInfoVO = new PayAuditInfoVO();
            if (StringUtils.isNotBlank(response)) {
                log.info("付款单据明细,response={}", JSONObject.parseObject(response));
                JSONObject jsonObject = (JSONObject) JSONObject.parse(response);
                String items = jsonObject.getString(URLConstant.RETURN_ITEMS);
                log.info("付款单据明细,items={}", jsonObject.getString(URLConstant.RETURN_ITEMS));
                JSONObject itemsObject = JSONObject.parseObject(items);
                String payOrderResDto = itemsObject.getString(URLConstant.RETURN_PAYORDERRESDTO);
                PayOrderVO payOrderVO = JSON.parseObject(payOrderResDto, PayOrderVO.class);
                BigDecimal payAmount = payOrderVO.getPayAmount().setScale(2, RoundingMode.HALF_UP);
                payOrderVO.setPayAmount(payAmount);
                payOrderVO.setPayAmountString(payAmount.toString());
                payAuditInfoVO.setPayOrderResDto(payOrderVO);
                return ServerResponse.createBySuccess(payAuditInfoVO);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ServerResponse.createBySuccess();
    }

    /**
     * 付款订单明细
     */
    @RequestMapping(value = "payPoRelationDetail", method = {RequestMethod.GET, RequestMethod.POST})
    public ServerResponse<PayAuditInfoVO> payPoRelationDetail(AuditVO auditVO) {
        try {
            String url = URLConstant.PAY_ORDER_DETAIL + auditVO.getPayId();
            log.info("url={}", url);
            String response = restTemplate.getForObject(url, String.class);
            PayAuditInfoVO payAuditInfoVO = new PayAuditInfoVO();
            if (StringUtils.isNotBlank(response)) {
                log.info("付款订单明细,response={}", JSONObject.parseObject(response));
                JSONObject jsonObject = (JSONObject) JSONObject.parse(response);
                String items = jsonObject.getString(URLConstant.RETURN_ITEMS);
                log.info("付款订单明细,items={}", jsonObject.getString(URLConstant.RETURN_ITEMS));
                JSONObject itemsObject = JSONObject.parseObject(items);
                String payPoRelationResDto = itemsObject.getString(URLConstant.RETURN_PAYPORELATIONRESDTO);
                List<PayPoRelationVO> payPoRelationVOS = JSON.parseArray(payPoRelationResDto, PayPoRelationVO.class);
                payAuditInfoVO.setPayPoRelationResDto(payPoRelationVOS);
                String payTotalVO = itemsObject.getString("payTotalVO");
                payAuditInfoVO.setPayTotalVO(JSON.parseObject(payTotalVO, PayTotalVO.class));
                return ServerResponse.createBySuccess(payAuditInfoVO);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ServerResponse.createBySuccess();
    }

    /**
     * 付款预收明细
     */
    @RequestMapping(value = "/payAdvanceDetail", method = {RequestMethod.GET, RequestMethod.POST})
    public ServerResponse<PayAuditInfoVO> payAdvanceDetail(AuditVO auditVO) {
        try {
            String url = URLConstant.PAY_ORDER_DETAIL + auditVO.getPayId();
            log.info("url={}", url);
            String response = restTemplate.getForObject(url, String.class);
            PayAuditInfoVO payAuditInfoVO = new PayAuditInfoVO();
            if (StringUtils.isNotBlank(response)) {
                log.info("付款预收明细,response={}", JSONObject.parseObject(response));
                JSONObject jsonObject = (JSONObject) JSONObject.parse(response);
                String items = jsonObject.getString(URLConstant.RETURN_ITEMS);
                log.info("付款预收明细,items={}", jsonObject.getString(URLConstant.RETURN_ITEMS));
                JSONObject itemsObject = JSONObject.parseObject(items);
                String payAdvanceRelation = itemsObject.getString(URLConstant.RETURN_PAYADVANCERELATION);
                List<PayAdvanceRelationVO> payAdvanceRelationVOS = JSON.parseArray(payAdvanceRelation, PayAdvanceRelationVO.class);
                payAuditInfoVO.setPayAdvanceRelation(payAdvanceRelationVOS);
                return ServerResponse.createBySuccess(payAuditInfoVO);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ServerResponse.createBySuccess();
    }
}
