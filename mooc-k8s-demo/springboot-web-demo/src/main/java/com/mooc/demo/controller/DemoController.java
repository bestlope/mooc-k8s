package com.mooc.demo.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by Michael on 2018/9/29.
 */

@RestController
public class DemoController {

    @RequestMapping("/hello")
    public String sayHello(@RequestParam String name) {

        return "Hello "+name+"! I'm springboot-web-demo controller!";

    }
}
