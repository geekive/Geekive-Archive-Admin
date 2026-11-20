package com.geekive.geekiveArchiveAdmin.mapper.service;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.geekive.geekiveArchiveAdmin.common.Constants;
import com.geekive.geekiveArchiveAdmin.common.CryptoUtil;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.LoginMapper;
import com.geekive.geekiveArchiveAdmin.mapper.UserMapper;

@Service
public class UserService implements UserMapper{
	
	@Autowired
    private CryptoUtil cryptoUtil;
	
	@Autowired
	UserMapper userMapper;

	@Autowired
	LoginMapper loginMapper;
	
	@Override
	public GeekiveMap selectUser(GeekiveMap gMap) {
		GeekiveMap userMap = userMapper.selectUser(gMap);
		try {
			userMap.put("email"		, cryptoUtil.decryptData(userMap.getString("email")));
			userMap.put("userName"	, cryptoUtil.decryptData(userMap.getString("userName")));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return userMap;
	}

	@Override
	public Boolean checkArchiveNameExistence(GeekiveMap gMap) {
		return userMapper.checkArchiveNameExistence(gMap);
	}

	@Override
	public Boolean checkArchiveNameUpaateAvailable(GeekiveMap gMap) {
		return userMapper.checkArchiveNameUpaateAvailable(gMap);
	}

	@Override
	public int updateUser(GeekiveMap gMap) {
		gMap.remove("previousArchiveName");
		String requestedArchiveName = gMap.getString("archiveName");
		boolean changeArchiveName = false;
		if (requestedArchiveName != null) {
			GeekiveMap currentProfile = userMapper.selectUser(gMap);
			if (currentProfile == null) {
				throw new IllegalArgumentException("Profile not found.");
			}
			String currentArchiveName = currentProfile.getString("archiveName");
			String archiveName = requestedArchiveName.trim();
			changeArchiveName = !archiveName.equals(currentArchiveName == null ? "" : currentArchiveName.trim());
			if (changeArchiveName) {
				if (archiveName.isEmpty()) {
					throw new IllegalArgumentException("Fill in archive name.");
				}
				gMap.put("archiveName", archiveName);
				if (Arrays.asList(Constants.BANNED_ARCHIVE_NAME).contains(archiveName) || checkArchiveNameExistence(gMap)) {
					throw new IllegalArgumentException("The archive name has already been signed up. Please try another archive name.");
				}
				if (!"Y".equals(currentProfile.getString("flagArchiveNameUpdateAvailable"))) {
					throw new IllegalArgumentException("Archive name cannot be updated for 1 week since the last update.");
				}
				gMap.put("previousArchiveName", currentArchiveName);
			} else {
				gMap.remove("archiveName");
			}
		}
		gMap.remove("currentPasswordHash");
		String currentPassword = gMap.getString("currentPassword");
		String password = gMap.getString("password");
		String confirmation = gMap.getString("passwordCheck");
		boolean changePassword = Util.isNotEmpty(password) || Util.isNotEmpty(confirmation);
		if (changePassword) {
			if (Util.isEmpty(password) || !password.equals(confirmation)) {
				throw new IllegalArgumentException("Passwords do not match.");
			}
			if (!password.matches("(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?:{}|<>_\\-])[A-Za-z0-9!@#$%^&*(),.?:{}|<>_\\-]{10,72}")) {
				throw new IllegalArgumentException("Use 10–72 characters, including a letter, a number, and a special character.");
			}
			if (Util.isEmpty(currentPassword)) {
				throw new IllegalArgumentException("Enter your current password.");
			}
			GeekiveMap loginQuery = new GeekiveMap();
			loginQuery.put("userUid", gMap.getString("userUid"));
			GeekiveMap account = loginMapper.selectUser(loginQuery);
			String currentPasswordHash = account == null ? null : account.getString("password");
			if (Util.isEmpty(currentPasswordHash) || !cryptoUtil.checkPassword(currentPassword, currentPasswordHash)) {
				throw new IllegalArgumentException("The current password is incorrect. Please try again.");
			}
			gMap.put("currentPasswordHash", currentPasswordHash);
			gMap.put("password", cryptoUtil.encryptPassword(password));
		} else {
			gMap.remove("password");
		}
		gMap.remove("currentPassword");
		gMap.remove("passwordCheck");
		try {
			gMap.put("userName", cryptoUtil.encryptData(gMap.getString("userName")));
		} catch (Exception e) {
			throw new IllegalStateException("Could not encrypt profile data.", e);
		}
		int updated = userMapper.updateUser(gMap);
		if (changeArchiveName && updated != 1) {
			throw new IllegalArgumentException("Your profile has changed. Refresh the page and try again.");
		}
		if (changePassword && updated != 1) {
			throw new IllegalArgumentException("Your password has changed. Enter your current password and try again.");
		}
		return updated;
	}
	
	@Override
	public int deleteUser(GeekiveMap gMap) {
		return userMapper.deleteUser(gMap);
	}

	@Override
	public List<GeekiveMap> selectSocialMedia(GeekiveMap gMap) {
		return userMapper.selectSocialMedia(gMap);
	}

	@Override
	public int insertSocialMedia(GeekiveMap gMap) {
		return userMapper.insertSocialMedia(gMap);
	}
	
	@Override
	public int deleteSocialMeida(GeekiveMap gMap) {
		return userMapper.deleteSocialMeida(gMap);
	}
}
