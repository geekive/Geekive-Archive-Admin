package com.geekive.geekiveArchiveAdmin.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.HandlerMapping;

import com.geekive.geekiveArchiveAdmin.common.Constants;
import com.geekive.geekiveArchiveAdmin.common.JwtUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.LoginService;

import io.jsonwebtoken.JwtException;
	
@Component
public class LoginInterceptor implements HandlerInterceptor {
	
	private final LoginService loginService;
	private final JwtUtil jwtUtil;

    public LoginInterceptor(JwtUtil jwtUtil, LoginService loginService) {
        this.jwtUtil 		= jwtUtil;
        this.loginService 	= loginService;
    }
    
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		HttpSession session = request.getSession(false);
		String signinType = session == null ? null : (String) session.getAttribute("signinType");
		GeekiveMap sessionUser = session == null ? null : (GeekiveMap) session.getAttribute("userMap");
		boolean signedIn = sessionUser != null && Boolean.TRUE.equals(session.getAttribute("isSignedIn"));
		boolean normalLogin = signedIn && Constants.SIGNIN_TYPE_NORMAL.equals(signinType);
		boolean handoff = "/sso".equals(request.getAttribute(HandlerMapping.BEST_MATCHING_PATTERN_ATTRIBUTE));
		if (normalLogin && !handoff) {
			return allowSession(request, response, session);
		}

		boolean jwtSession = signedIn && Constants.SIGNIN_TYPE_JWT.equals(signinType);
		String tokenUserUid = handoff || jwtSession ? getTokenUserUid(request) : null;
		if (jwtSession && tokenUserUid != null && tokenUserUid.equals(sessionUser.getString("userUid"))) {
			return allowSession(request, response, session);
		}

		if (handoff && tokenUserUid != null) {
			GeekiveMap userMap = loginService.findJwtUser(tokenUserUid);
			if (userMap != null) {
				LoginService.startSession(request, userMap, Constants.SIGNIN_TYPE_JWT);
				return allowSession(request, response, request.getSession(false));
			}
		}
		if (!normalLogin && session != null && (signinType != null || sessionUser != null || session.getAttribute("isSignedIn") != null)) {
			session.invalidate();
		}
		if (!handoff && request.getHeader("X-Admin-Session") != null) {
			return rejectStalePage(response);
		}
		response.sendRedirect(handoff ? Util.getUserServerUrl().replaceAll("/+$", "") + "/sign/signin"
				: request.getContextPath() + "/login");
		return false;
	}

	private boolean allowSession(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
		String pageSession = request.getHeader("X-Admin-Session");
		if (pageSession != null && !pageSession.equals(session.getAttribute("adminSessionContext"))) {
			return rejectStalePage(response);
		}
		response.setHeader("Cache-Control", "no-store");
		return true;
	}

	private boolean rejectStalePage(HttpServletResponse response) {
		response.setHeader("X-Admin-Session-Changed", "true");
		response.setStatus(HttpServletResponse.SC_CONFLICT);
		return false;
	}

	private String getTokenUserUid(HttpServletRequest request) {
		String token = jwtUtil.getTokenFromCookie(request);
		if (Util.isEmpty(token)) {
			return null;
		}
		try {
			String userUid = jwtUtil.extractValue(token);
			return Util.isEmpty(userUid) ? null : userUid;
		} catch (JwtException | IllegalArgumentException e) {
			return null;
		}
	}

}
