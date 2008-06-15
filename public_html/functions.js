function distroAndSection() {
	var distro = location.href.replace(/^.*\/manpages\//, "");
	distro = distro.replace(/\/.*$/, "");
	distro = distro.replace(/^.*:/, "");
	var section = location.href.replace(/^.*\/manpages\/.*\/man/, "");
	section = section.replace(/\/.*$/, "");
	section = section.replace(/^.*:/, "");
	if (distro.length > 0) {
		document.write(" - <a href=../>" + distro + "</a> ");
		if (section.length > 0) {
			document.write("(<a href=../man" + section + ">" + section + "</a>)");
		}
	}
}
function highlight(word) {
        if (location.href.match("/" + word)) {
                return("current");
        } else {
                return("plain");
        }
}
function navbar() {
        document.write("<ul>");
        versions = new Array();
        versions.push({"name":"dapper", "number":"6.06 LTS"});
        versions.push({"name":"feisty", "number":"7.04"});
        versions.push({"name":"gutsy", "number":"7.10"});
        versions.push({"name":"hardy", "number":"8.04 LTS"});
        versions.push({"name":"intrepid", "number":"8.10"});
        for (var i=0; i<versions.length; i++) {
                document.write("<li id=" + highlight(versions[i]["name"]) + "><a href=/manpages/" + versions[i]["name"] + ">" + versions[i]["number"] + "</a></li>");
        }
        document.write("</ul>");
}
