package com.wx.cp.error;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * <pre>
 * 出错页面控制器
 * Created by qm on 2018/8/25.
 * </pre>
 *
 * @author <a href="">qm</a>
 */
@Controller
@RequestMapping("/error")
public class ErrorController {

  @GetMapping(value = "/404")
  public String error404() {
    return "error";
  }

  @GetMapping(value = "/500")
  public String error500() {
    return "error";
  }

}
