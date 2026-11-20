package com.geekive.geekiveArchiveAdmin.controller;

import java.util.Arrays;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.geekive.geekiveArchiveAdmin.common.Constants;
import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveConnector;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.UserService;

@Controller
@RequestMapping(value = "/user")
public class UserController {

	@Resource
	UserService userService;
	
	@GetMapping(value = "/profile")
	public String progile(HttpServletRequest request, ModelMap modelMap) throws Exception{
		GeekiveMap userMap = userService.selectUser(new GeekiveMap());
		modelMap.put("userMap", userMap);
		return "user/profile/profile";
	}
	
	@ResponseBody
	@PostMapping(value = "/check-archive-name-existence")
	public GeekiveMap checkArchiveNameExistence(@RequestBody GeekiveMap gMap) throws Exception{
		try {
			if(userService.checkArchiveNameExistence(gMap)) {
				throw new Exception("The archive name has already been signed up. Please try another archive name.");
			}
			if(Arrays.asList(Constants.BANNED_ARCHIVE_NAME).contains(gMap.getString("archiveName"))) {
				throw new Exception("The archive name has already been signed up. Please try another archive name.");
			}
		} catch (Exception e) {
			gMap.setResultCode(0);
			gMap.setResultMessage(e.getMessage());
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/check-archive-name-update-available")
	public GeekiveMap checkArchiveNameUpdateAvailable(@RequestBody GeekiveMap gMap) throws Exception{
		try {
			if(!userService.checkArchiveNameUpaateAvailable(new GeekiveMap())) {
				throw new Exception("Archive name cannot be updated for 1 week since the last update.");
			}
		} catch (Exception e) {
			gMap.setResultCode(0);
			gMap.setResultMessage(e.getMessage());
		}
		return gMap;
	}
	
	@ResponseBody
	@PostMapping(value = "/save-profile", consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE})
	public GeekiveMap saveProfile(@RequestPart(value = "profileImage", required = false) MultipartFile thumbnail, @RequestPart("data") GeekiveMap gMap) throws Exception{
		GeekiveMap response = new GeekiveMap();
		gMap.put("userUid", response.getString("userUid"));
		String url = Util.getFileServerUploadUrl() + "/file";
		
		try {
			if(thumbnail != null) {
				GeekiveConnector gConntector = new GeekiveConnector.Builder(url).data(thumbnail).build();
				GeekiveMap responseMap = gConntector.sendMultiPartFile("file");
				gMap.put("profileImageUid", responseMap.getString("fileUid"));
			}
			
			userService.updateUser(gMap);
			response.setResultMessage("Your request is complete.");
		} catch (IllegalArgumentException e) {
			response.setResultCode(0);
			response.setResultMessage(e.getMessage());
		} catch (Exception e) {
			response.setResultCode(0);
			response.setResultMessage("Could not save your profile. Please try again.");
		}
		return response;
	}
	
	@ResponseBody
	@PostMapping(value = "/delete-user")
	public GeekiveMap deleteUser(HttpSession session) throws Exception{
		GeekiveMap gMap = new GeekiveMap();
		try {
			userService.deleteUser(gMap);
			gMap.setResultMessage("Thank you for using Geekive Archive.");
			session.invalidate();
		} catch (Exception e) {
			gMap.setResultCode(0);
			gMap.setResultMessage(e.getMessage());
		}
		return gMap;
	}
	
	@GetMapping(value = "/socialmedia")
	public String socialmedia(HttpServletRequest request, ModelMap modelMap) throws Exception{
		List<GeekiveMap> socialMediaList = userService.selectSocialMedia(new GeekiveMap());
		modelMap.put("socialMediaList", socialMediaList);
		return "user/socialmedia/socialmedia";
	}
	
	@ResponseBody
	@PostMapping(value = "/save-socialmedia", consumes = MediaType.APPLICATION_JSON_VALUE)
	public GeekiveMap socialmediaSave(@RequestBody List<GeekiveMap> socialMediaList) throws Exception{
		GeekiveMap gMap = new GeekiveMap();
		try {
			userService.deleteSocialMeida(gMap);
			for(GeekiveMap socialMedia : socialMediaList) {
				socialMedia.put("socialMediaUid", Util.generateUID("SMD"));
	            userService.insertSocialMedia(socialMedia);
	        }
		} catch (Exception e) {
			gMap.put("resultCode"	, 0);
			gMap.put("resultMessage", e.getMessage());
		}
		return gMap;
	}
}
