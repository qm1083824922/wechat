package com.wx.cp.handler;

import com.wx.cp.builder.TextBuilder;
import com.wx.cp.utils.JsonUtils;
import me.chanjar.weixin.common.session.WxSessionManager;
import me.chanjar.weixin.cp.api.WxCpService;
import me.chanjar.weixin.cp.bean.WxCpXmlMessage;
import me.chanjar.weixin.cp.bean.WxCpXmlOutMessage;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 通讯录变更事件处理器.
 *
 * @author qm
 */
@Component
public class ContactChangeHandler extends AbstractHandler {

  @Override
  public WxCpXmlOutMessage handle(WxCpXmlMessage wxMessage, Map<String, Object> context, WxCpService cpService,
                                  WxSessionManager sessionManager) {
    String content = "收到通讯录变更事件，内容：" + JsonUtils.toJson(wxMessage);
    this.logger.info(content);

    return new TextBuilder().build(content, wxMessage, cpService);
  }

}
