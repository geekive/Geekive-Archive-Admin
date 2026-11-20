package com.geekive.geekiveArchiveAdmin.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import com.geekive.geekiveArchiveAdmin.common.MessageUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.mapper.service.CommonService;

@Component
public class CommonDataInterceptor implements HandlerInterceptor {

	private final CommonService commonService;

    public CommonDataInterceptor(CommonService commonService) {
        this.commonService = commonService;
    }
	
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {
		if(modelAndView != null) {
			if (!modelAndView.getModel().containsKey("isLogin")) {
				modelAndView.addObject("isLogin", Util.isLogin(request));
			}
			modelAndView.addObject("contextPath"	, request.getContextPath());
			modelAndView.addObject("subPath"		, Util.getSubPath(request));
			
			String[] subPathArray 	= Util.splitSubPath(Util.getSubPath(request));
			String currentMenuTitle = MessageUtil.getMessage("common.home");
			if(subPathArray != null) {
				currentMenuTitle = commonService.selectSelectedMenuTitle("/" + String.join("/", subPathArray), MessageUtil.isKorean());
			}
			modelAndView.addObject("currentMenuTitle", currentMenuTitle);
        }
	}
}
