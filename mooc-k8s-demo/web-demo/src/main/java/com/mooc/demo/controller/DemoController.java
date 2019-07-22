package com.mooc.demo.controller;

import com.mooc.demo.api.DemoService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.ContextLoader;

/**
 * Created by Michael on 2018/9/26.
 */
@Controller
public class DemoController {

    private static final Logger log = LoggerFactory.getLogger(DemoController.class);

    @Autowired
    private DemoService demoService;

    @RequestMapping("/hello")
    @ResponseBody
    public String sayHello(@RequestParam String name) {

        log.debug("say hello to :{}", name);

        String message = demoService.sayHello(name);

        log.debug("dubbo result:{}", message);

        return message;

    }
}
