package com.mooc.demo.service;

import com.mooc.demo.api.DemoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by Michael on 2018/9/25.
 */
public class DemoServiceImpl implements DemoService {

    private static final Logger log = LoggerFactory.getLogger(DemoServiceImpl.class);

    public String sayHello(String name) {

        log.debug("dubbo say hello to : {}", name);

        return "Hello "+name;
    }

}
