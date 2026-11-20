package com.geekive.geekiveArchiveAdmin.mapper.service;

import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.geekive.geekiveArchiveAdmin.common.CryptoUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.LoginMapper;

@Service
public class LoginService {
	
	@Autowired
    private CryptoUtil cryptoUtil;
	
	@Autowired
	LoginMapper loginMapper;

	public int checkEmail(String email) throws Exception {
		if (Util.isEmpty(email)) {
			return 0;
		}
		GeekiveMap query = new GeekiveMap();
		query.put("email", cryptoUtil.encryptData(email));
		return loginMapper.checkEmail(query);
	}

	public GeekiveMap authenticate(String email, String password) throws Exception {
		if (Util.isEmpty(email) || Util.isEmpty(password)) {
			return null;
		}
		GeekiveMap query = new GeekiveMap();
		query.remove("userUid");
		query.put("email", cryptoUtil.encryptData(email));
		GeekiveMap userMap = loginMapper.selectUser(query);
		if (userMap == null || !cryptoUtil.checkPassword(password, userMap.getString("password"))) {
			return null;
		}
		return prepareUser(userMap);
	}

	public GeekiveMap findJwtUser(String userUid) {
		GeekiveMap query = new GeekiveMap();
		query.put("userUid", userUid);
		try {
			GeekiveMap userMap = loginMapper.selectUser(query);
			return userMap == null ? null : prepareUser(userMap);
		} catch (Exception e) {
			return null;
		}
	}

	private GeekiveMap prepareUser(GeekiveMap userMap) throws Exception {
		userMap.remove("password");
		userMap.put("userName", cryptoUtil.decryptData(userMap.getString("userName")));
		userMap.put("myArchiveFullUrlPath", Util.getUserServerUrl() + userMap.getString("myArchiveUrlPath"));
		return userMap;
	}

	public static void startSession(HttpServletRequest request, GeekiveMap userMap, String signinType) {
		HttpSession previous = request.getSession(false);
		if (previous != null) {
			previous.invalidate();
		}
		HttpSession session = request.getSession();
		session.setAttribute("userMap", userMap);
		session.setAttribute("signinType", signinType);
		session.setAttribute("isSignedIn", true);
		session.setAttribute("adminSessionContext", UUID.randomUUID().toString());
	}
}
