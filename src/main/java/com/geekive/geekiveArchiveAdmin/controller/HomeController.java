package com.geekive.geekiveArchiveAdmin.controller;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.service.HomeService;


@Controller
public class HomeController {
	
	@Resource
	HomeService homeService;

	@GetMapping(value = {"", "/index", "/home"})
	public String index(ModelMap modelMap) throws Exception{
		List<GeekiveMap> trafficTrendList = homeService.selectTrafficTrendForMyArchive(new GeekiveMap());
		modelMap.put("trafficTrendList", trafficTrendList);
		
		List<GeekiveMap> top5ArticleList = homeService.selectTop5MostViewedArticlesInTheLast30Days(new GeekiveMap());
		modelMap.put("top5ArticleList", top5ArticleList);
		
		return "home/home";
	}

	@GetMapping(value = "/sso")
	public String sso() {
		return "redirect:/";
	}
	
	@ResponseBody
	@PostMapping(value = "/errorImage")
	public String errorImage(@RequestBody GeekiveMap gMap) throws Exception{
		String storageServerUrl = Util.getStorageUrl();
		switch (gMap.getString("type")) {
		case "profile":
			storageServerUrl += "/image/profile/basic.jpg";
			break;
		case "thumbnail":
			storageServerUrl += "/image/article/no_thumbnail.png";
			break;
		default:
			break;
		}
		return storageServerUrl;
	}
}
