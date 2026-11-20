package com.geekive.geekiveArchiveAdmin.controller;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.geekive.geekiveArchiveAdmin.common.MessageUtil;
import com.geekive.geekiveArchiveAdmin.common.Constants;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.LoginService;

@Controller
@RequestMapping(value = "login")
public class LoginController {
	
	@Resource
	LoginService loginService;

	@GetMapping(value = {"", "/"})
	public String login(HttpServletRequest request, Model model) {
		HttpSession session = request.getSession(false);
		if (session != null && Constants.SIGNIN_TYPE_NORMAL.equals(session.getAttribute("signinType")) && Util.isLogin(request)) {
			return "redirect:/";
		}
		model.addAttribute("isLogin", false);
		return "login/login";
	}
	
	@ResponseBody
	@PostMapping(value = "/check-email")
	public GeekiveMap checkEmail(@RequestBody GeekiveMap gMap) {
		GeekiveMap response = new GeekiveMap();
		response.remove("userUid");
		try {
			if(loginService.checkEmail(gMap.getString("email")) != 1) {
				throw new IllegalArgumentException(MessageUtil.getMessage("login.accountUnavailable"));
			}
		} catch (Exception e) {
			response.setResultCode(0);
			response.setResultMessage(e instanceof IllegalArgumentException ? e.getMessage() : MessageUtil.getMessage("common.error"));
		}
		return response;
	}
	
	@ResponseBody
	@PostMapping(value = "/check-password")
	public GeekiveMap checkPassword(HttpServletRequest request, @RequestBody GeekiveMap gMap) {
		GeekiveMap response = new GeekiveMap();
		response.remove("userUid");
		try {
			GeekiveMap userMap = loginService.authenticate(gMap.getString("email"), gMap.getString("password"));
			if(Util.isEmpty(userMap)) {
				throw new IllegalArgumentException(MessageUtil.getMessage("login.incorrectPassword"));
			}
			LoginService.startSession(request, userMap, Constants.SIGNIN_TYPE_NORMAL);
		} catch (Exception e) {
			response.setResultCode(0);
			response.setResultMessage(e instanceof IllegalArgumentException ? e.getMessage() : MessageUtil.getMessage("common.error"));
		}
		return response;
	}
	
	@GetMapping(value = "/logout")
	public String logout(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session != null && Constants.SIGNIN_TYPE_JWT.equals(session.getAttribute("signinType"))) {
			return "redirect:/";
		}
		if (session != null) {
			session.invalidate();
		}
		return "redirect:/login";
	}
}
