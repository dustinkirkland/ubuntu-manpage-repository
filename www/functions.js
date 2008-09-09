// This is the Ubuntu manpage repository generator and interface.
//
// Copyright (C) 2008 Canonical Ltd.
//
// This code was originally written by Dustin Kirkland <kirkland@ubuntu.com>,
// based on a framework by Kees Cook <kees@ubuntu.com>.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// On Debian-based systems, the complete text of the GNU General Public
// License can be found in /usr/share/common-licenses/GPL-3


function distroAndSection() {
	var distro = location.href.split("/")[4];
	var section = location.href.split("/")[5];
	section = section.replace(/^man/, "");
	if (!(section >= 1 && section <= 9)) {
		section = location.href.split("/")[6];
		section = section.replace(/^man/, "");
		var lang = location.href.split("/")[5];
	}
	if (distro.length > 0) {
		document.write(" - <a href=\"../\">" + distro + "</a> ");
		if (section.length > 0) {
			document.write("(<a href=\"../man" + section + "\">" + section + "</a>)");
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
                document.write("<li id=\"" + highlight(versions[i]["name"]) + "\"><a href=\"/manpages/" + versions[i]["name"] + "\">" + versions[i]["number"] + "</a></li>");
        }
        document.write("</ul>");
}


/////////////////////////////////////////////////////////////////////////////////////
// This script was written By Brady Mulhollem - WebTech101.com
// http://www.webtech101.com/Javascript/toc-generator
window.onload = function(){new tocGen('top','toc')};
function tocGen(id,writeTo){
	this.id = id;
	this.num = 0;
	this.opened = 0;
	this.writeOut = '';
	this.previous = 0;
	if(document.getElementById){
		//current requirements;
		this.parentOb = document.getElementById(id);
		var headers = this.getHeaders(this.parentOb);
		if(headers.length > 0){
			this.writeOut += '<ul>';
			var num;
			for(var i=0;i<headers.length;i++){
				num = headers[i].nodeName.substr(1);
				if(num > this.previous){
					this.writeOut += '<ul>';
					this.opened++;
					this.addLink(headers[i]);
				}
				else if(num < this.previous){
					for(var j=0;j<this.opened;j++){
						this.writeOut += '<\/li><\/ul>';
						this.opened--;
					}
					this.addLink(headers[i]);
				}
				else{
					this.writeout += '<\/li>';
					this.addLink(headers[i]);
				}
				this.previous = num;
			}
			for(var j=0;j<=this.opened;j++){
				this.writeOut += '<\/li><\/ul>';
			}
			document.getElementById(writeTo).innerHTML = this.writeOut;
		}
	}
}
tocGen.prototype.addLink = function(ob){
	var id = this.getId(ob);
	var link = '<li><a href="#'+id+'">'+ob.innerHTML+'<\/a>';
	this.writeOut += link;
}
tocGen.prototype.getId = function(ob){
	if(!ob.id){
		ob.id = this.id+'toc'+this.num;
		this.num++;
	}
	return ob.id;
}
tocGen.prototype.getHeaders = function(parent){
	var return_array = new Array();
	var pat = new RegExp("H[1-6]");
	for(var i=0;i<parent.childNodes.length;i++){
		if(pat.test(parent.childNodes[i].nodeName)){
			return_array[return_array.length] = parent.childNodes[i];
		}
	}
	return return_array;
}
/////////////////////////////////////////////////////////////////////////////////////