Number.EPSILON===void 0&&(Number.EPSILON=Math.pow(2,-52));Number.isInteger===void 0&&(Number.isInteger=function(e){return typeof e=="number"&&isFinite(e)&&Math.floor(e)===e});Math.sign===void 0&&(Math.sign=function(e){return e<0?-1:e>0?1:+e});"name"in Function.prototype||Object.defineProperty(Function.prototype,"name",{get:function(){return this.toString().match(/^\s*function\s*([^\(\s]*)/)[1]}});Object.assign===void 0&&function(){Object.assign=function(e){if(e==null)throw new TypeError("Cannot convert undefined or null to object");for(var t=Object(e),r=1;r<arguments.length;r++){var i=arguments[r];if(i!=null)for(var n in i)Object.prototype.hasOwnProperty.call(i,n)&&(t[n]=i[n])}return t}}();function ar(){}Object.assign(ar.prototype,{addEventListener:function(e,t){this._listeners===void 0&&(this._listeners={});var r=this._listeners;r[e]===void 0&&(r[e]=[]),r[e].indexOf(t)===-1&&r[e].push(t)},hasEventListener:function(e,t){if(this._listeners===void 0)return!1;var r=this._listeners;return r[e]!==void 0&&r[e].indexOf(t)!==-1},removeEventListener:function(e,t){if(this._listeners!==void 0){var r=this._listeners,i=r[e];if(i!==void 0){var n=i.indexOf(t);n!==-1&&i.splice(n,1)}}},dispatchEvent:function(e){if(this._listeners!==void 0){var t=this._listeners,r=t[e.type];if(r!==void 0){e.target=this;for(var i=r.slice(0),n=0,a=i.length;n<a;n++)i[n].call(this,e)}}}});var eh=0,is=1,th=2,Xs=1,rh=2,Bi=0,st=1,Ni=2,js=1,qs=0,Ys=1,Wr=2,Jr=0,br=1,sa=2,oa=3,ha=4,Zs=5,_r=100,ih=101,nh=102,Jn=103,Qn=104,ah=200,sh=201,oh=202,hh=203,Js=204,Qs=205,ch=206,uh=207,lh=208,fh=209,dh=210,ph=0,mh=1,vh=2,ca=3,gh=4,yh=5,xh=6,_h=7,Hn=0,wh=1,bh=2,Kn=0,Ks=1,Mh=2,Eh=3,Th=4,Sh=5,ka=300,Wa=301,ua=302,$s=303,la=304,eo=305,Xa=306,ja=307,Qt=1e3,Et=1001,Er=1002,et=1003,qa=1004,Ya=1005,it=1006,to=1007,Vn=1008,kn=1009,Ah=1010,Lh=1011,Zi=1012,Rh=1013,ro=1014,$r=1015,Za=1016,Ph=1017,Ch=1018,Ih=1019,Ji=1020,Dh=1021,cr=1022,Wt=1023,Oh=1024,Fh=1025,Mr=1026,ei=1027,Uh=1028,ns=33776,as=33777,ss=33778,os=33779,hs=35840,cs=35841,us=35842,ls=35843,Bh=36196,Nh=37808,Gh=37809,zh=37810,Hh=37811,Vh=37812,kh=37813,Wh=37814,Xh=37815,jh=37816,qh=37817,Yh=37818,Zh=37819,Jh=37820,Qh=37821,Kh=2200,$h=2201,ec=2202,Qi=2300,Yi=2301,$n=2302,Tr=2400,wr=2401,Ki=2402,io=0,tc=1,rc=2,$i=3e3,ic=3001,no=3007,nc=3002,ac=3004,sc=3005,oc=3006,hc=3200,cc=3201,Wn=0,uc=1,ge={DEG2RAD:Math.PI/180,RAD2DEG:180/Math.PI,generateUUID:function(){for(var e=[],t=0;t<256;t++)e[t]=(t<16?"0":"")+t.toString(16);return function(){var i=Math.random()*4294967295|0,n=Math.random()*4294967295|0,a=Math.random()*4294967295|0,s=Math.random()*4294967295|0,o=e[i&255]+e[i>>8&255]+e[i>>16&255]+e[i>>24&255]+"-"+e[n&255]+e[n>>8&255]+"-"+e[n>>16&15|64]+e[n>>24&255]+"-"+e[a&63|128]+e[a>>8&255]+"-"+e[a>>16&255]+e[a>>24&255]+e[s&255]+e[s>>8&255]+e[s>>16&255]+e[s>>24&255];return o.toUpperCase()}}(),clamp:function(e,t,r){return Math.max(t,Math.min(r,e))},euclideanModulo:function(e,t){return(e%t+t)%t},mapLinear:function(e,t,r,i,n){return i+(e-t)*(n-i)/(r-t)},lerp:function(e,t,r){return(1-r)*e+r*t},smoothstep:function(e,t,r){return e<=t?0:e>=r?1:(e=(e-t)/(r-t),e*e*(3-2*e))},smootherstep:function(e,t,r){return e<=t?0:e>=r?1:(e=(e-t)/(r-t),e*e*e*(e*(e*6-15)+10))},randInt:function(e,t){return e+Math.floor(Math.random()*(t-e+1))},randFloat:function(e,t){return e+Math.random()*(t-e)},randFloatSpread:function(e){return e*(.5-Math.random())},degToRad:function(e){return e*ge.DEG2RAD},radToDeg:function(e){return e*ge.RAD2DEG},isPowerOfTwo:function(e){return(e&e-1)===0&&e!==0},ceilPowerOfTwo:function(e){return Math.pow(2,Math.ceil(Math.log(e)/Math.LN2))},floorPowerOfTwo:function(e){return Math.pow(2,Math.floor(Math.log(e)/Math.LN2))}};function z(e,t){this.x=e||0,this.y=t||0}Object.defineProperties(z.prototype,{width:{get:function(){return this.x},set:function(e){this.x=e}},height:{get:function(){return this.y},set:function(e){this.y=e}}});Object.assign(z.prototype,{isVector2:!0,set:function(e,t){return this.x=e,this.y=t,this},setScalar:function(e){return this.x=e,this.y=e,this},setX:function(e){return this.x=e,this},setY:function(e){return this.y=e,this},setComponent:function(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;default:throw new Error("index is out of range: "+e)}return this},getComponent:function(e){switch(e){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+e)}},clone:function(){return new this.constructor(this.x,this.y)},copy:function(e){return this.x=e.x,this.y=e.y,this},add:function(e,t){return t!==void 0?(console.warn("THREE.Vector2: .add() now only accepts one argument. Use .addVectors( a, b ) instead."),this.addVectors(e,t)):(this.x+=e.x,this.y+=e.y,this)},addScalar:function(e){return this.x+=e,this.y+=e,this},addVectors:function(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this},addScaledVector:function(e,t){return this.x+=e.x*t,this.y+=e.y*t,this},sub:function(e,t){return t!==void 0?(console.warn("THREE.Vector2: .sub() now only accepts one argument. Use .subVectors( a, b ) instead."),this.subVectors(e,t)):(this.x-=e.x,this.y-=e.y,this)},subScalar:function(e){return this.x-=e,this.y-=e,this},subVectors:function(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this},multiply:function(e){return this.x*=e.x,this.y*=e.y,this},multiplyScalar:function(e){return this.x*=e,this.y*=e,this},divide:function(e){return this.x/=e.x,this.y/=e.y,this},divideScalar:function(e){return this.multiplyScalar(1/e)},applyMatrix3:function(e){var t=this.x,r=this.y,i=e.elements;return this.x=i[0]*t+i[3]*r+i[6],this.y=i[1]*t+i[4]*r+i[7],this},min:function(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this},max:function(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this},clamp:function(e,t){return this.x=Math.max(e.x,Math.min(t.x,this.x)),this.y=Math.max(e.y,Math.min(t.y,this.y)),this},clampScalar:function(){var e=new z,t=new z;return function(i,n){return e.set(i,i),t.set(n,n),this.clamp(e,t)}}(),clampLength:function(e,t){var r=this.length();return this.divideScalar(r||1).multiplyScalar(Math.max(e,Math.min(t,r)))},floor:function(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this},ceil:function(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this},round:function(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this},roundToZero:function(){return this.x=this.x<0?Math.ceil(this.x):Math.floor(this.x),this.y=this.y<0?Math.ceil(this.y):Math.floor(this.y),this},negate:function(){return this.x=-this.x,this.y=-this.y,this},dot:function(e){return this.x*e.x+this.y*e.y},cross:function(e){return this.x*e.y-this.y*e.x},lengthSq:function(){return this.x*this.x+this.y*this.y},length:function(){return Math.sqrt(this.x*this.x+this.y*this.y)},manhattanLength:function(){return Math.abs(this.x)+Math.abs(this.y)},normalize:function(){return this.divideScalar(this.length()||1)},angle:function(){var e=Math.atan2(this.y,this.x);return e<0&&(e+=2*Math.PI),e},distanceTo:function(e){return Math.sqrt(this.distanceToSquared(e))},distanceToSquared:function(e){var t=this.x-e.x,r=this.y-e.y;return t*t+r*r},manhattanDistanceTo:function(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)},setLength:function(e){return this.normalize().multiplyScalar(e)},lerp:function(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this},lerpVectors:function(e,t,r){return this.subVectors(t,e).multiplyScalar(r).add(e)},equals:function(e){return e.x===this.x&&e.y===this.y},fromArray:function(e,t){return t===void 0&&(t=0),this.x=e[t],this.y=e[t+1],this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this.x,e[t+1]=this.y,e},fromBufferAttribute:function(e,t,r){return r!==void 0&&console.warn("THREE.Vector2: offset has been removed from .fromBufferAttribute()."),this.x=e.getX(t),this.y=e.getY(t),this},rotateAround:function(e,t){var r=Math.cos(t),i=Math.sin(t),n=this.x-e.x,a=this.y-e.y;return this.x=n*r-a*i+e.x,this.y=n*i+a*r+e.y,this}});function fe(){this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],arguments.length>0&&console.error("THREE.Matrix4: the constructor no longer reads arguments. use .set() instead.")}Object.assign(fe.prototype,{isMatrix4:!0,set:function(e,t,r,i,n,a,s,o,h,c,u,l,f,d,p,m){var v=this.elements;return v[0]=e,v[4]=t,v[8]=r,v[12]=i,v[1]=n,v[5]=a,v[9]=s,v[13]=o,v[2]=h,v[6]=c,v[10]=u,v[14]=l,v[3]=f,v[7]=d,v[11]=p,v[15]=m,this},identity:function(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this},clone:function(){return new fe().fromArray(this.elements)},copy:function(e){var t=this.elements,r=e.elements;return t[0]=r[0],t[1]=r[1],t[2]=r[2],t[3]=r[3],t[4]=r[4],t[5]=r[5],t[6]=r[6],t[7]=r[7],t[8]=r[8],t[9]=r[9],t[10]=r[10],t[11]=r[11],t[12]=r[12],t[13]=r[13],t[14]=r[14],t[15]=r[15],this},copyPosition:function(e){var t=this.elements,r=e.elements;return t[12]=r[12],t[13]=r[13],t[14]=r[14],this},extractBasis:function(e,t,r){return e.setFromMatrixColumn(this,0),t.setFromMatrixColumn(this,1),r.setFromMatrixColumn(this,2),this},makeBasis:function(e,t,r){return this.set(e.x,t.x,r.x,0,e.y,t.y,r.y,0,e.z,t.z,r.z,0,0,0,0,1),this},extractRotation:function(){var e=new b;return function(r){var i=this.elements,n=r.elements,a=1/e.setFromMatrixColumn(r,0).length(),s=1/e.setFromMatrixColumn(r,1).length(),o=1/e.setFromMatrixColumn(r,2).length();return i[0]=n[0]*a,i[1]=n[1]*a,i[2]=n[2]*a,i[3]=0,i[4]=n[4]*s,i[5]=n[5]*s,i[6]=n[6]*s,i[7]=0,i[8]=n[8]*o,i[9]=n[9]*o,i[10]=n[10]*o,i[11]=0,i[12]=0,i[13]=0,i[14]=0,i[15]=1,this}}(),makeRotationFromEuler:function(e){e&&e.isEuler||console.error("THREE.Matrix4: .makeRotationFromEuler() now expects a Euler rotation rather than a Vector3 and order.");var t=this.elements,r=e.x,i=e.y,n=e.z,a=Math.cos(r),s=Math.sin(r),o=Math.cos(i),h=Math.sin(i),c=Math.cos(n),u=Math.sin(n);if(e.order==="XYZ"){var l=a*c,f=a*u,d=s*c,p=s*u;t[0]=o*c,t[4]=-o*u,t[8]=h,t[1]=f+d*h,t[5]=l-p*h,t[9]=-s*o,t[2]=p-l*h,t[6]=d+f*h,t[10]=a*o}else if(e.order==="YXZ"){var m=o*c,v=o*u,g=h*c,_=h*u;t[0]=m+_*s,t[4]=g*s-v,t[8]=a*h,t[1]=a*u,t[5]=a*c,t[9]=-s,t[2]=v*s-g,t[6]=_+m*s,t[10]=a*o}else if(e.order==="ZXY"){var m=o*c,v=o*u,g=h*c,_=h*u;t[0]=m-_*s,t[4]=-a*u,t[8]=g+v*s,t[1]=v+g*s,t[5]=a*c,t[9]=_-m*s,t[2]=-a*h,t[6]=s,t[10]=a*o}else if(e.order==="ZYX"){var l=a*c,f=a*u,d=s*c,p=s*u;t[0]=o*c,t[4]=d*h-f,t[8]=l*h+p,t[1]=o*u,t[5]=p*h+l,t[9]=f*h-d,t[2]=-h,t[6]=s*o,t[10]=a*o}else if(e.order==="YZX"){var w=a*o,y=a*h,S=s*o,R=s*h;t[0]=o*c,t[4]=R-w*u,t[8]=S*u+y,t[1]=u,t[5]=a*c,t[9]=-s*c,t[2]=-h*c,t[6]=y*u+S,t[10]=w-R*u}else if(e.order==="XZY"){var w=a*o,y=a*h,S=s*o,R=s*h;t[0]=o*c,t[4]=-u,t[8]=h*c,t[1]=w*u+R,t[5]=a*c,t[9]=y*u-S,t[2]=S*u-y,t[6]=s*c,t[10]=R*u+w}return t[3]=0,t[7]=0,t[11]=0,t[12]=0,t[13]=0,t[14]=0,t[15]=1,this},makeRotationFromQuaternion:function(){var e=new b(0,0,0),t=new b(1,1,1);return function(i){return this.compose(e,i,t)}}(),lookAt:function(){var e=new b,t=new b,r=new b;return function(n,a,s){var o=this.elements;return r.subVectors(n,a),r.lengthSq()===0&&(r.z=1),r.normalize(),e.crossVectors(s,r),e.lengthSq()===0&&(Math.abs(s.z)===1?r.x+=1e-4:r.z+=1e-4,r.normalize(),e.crossVectors(s,r)),e.normalize(),t.crossVectors(r,e),o[0]=e.x,o[4]=t.x,o[8]=r.x,o[1]=e.y,o[5]=t.y,o[9]=r.y,o[2]=e.z,o[6]=t.z,o[10]=r.z,this}}(),multiply:function(e,t){return t!==void 0?(console.warn("THREE.Matrix4: .multiply() now only accepts one argument. Use .multiplyMatrices( a, b ) instead."),this.multiplyMatrices(e,t)):this.multiplyMatrices(this,e)},premultiply:function(e){return this.multiplyMatrices(e,this)},multiplyMatrices:function(e,t){var r=e.elements,i=t.elements,n=this.elements,a=r[0],s=r[4],o=r[8],h=r[12],c=r[1],u=r[5],l=r[9],f=r[13],d=r[2],p=r[6],m=r[10],v=r[14],g=r[3],_=r[7],w=r[11],y=r[15],S=i[0],R=i[4],I=i[8],C=i[12],A=i[1],O=i[5],F=i[9],N=i[13],V=i[2],k=i[6],G=i[10],J=i[14],Y=i[3],q=i[7],E=i[11],T=i[15];return n[0]=a*S+s*A+o*V+h*Y,n[4]=a*R+s*O+o*k+h*q,n[8]=a*I+s*F+o*G+h*E,n[12]=a*C+s*N+o*J+h*T,n[1]=c*S+u*A+l*V+f*Y,n[5]=c*R+u*O+l*k+f*q,n[9]=c*I+u*F+l*G+f*E,n[13]=c*C+u*N+l*J+f*T,n[2]=d*S+p*A+m*V+v*Y,n[6]=d*R+p*O+m*k+v*q,n[10]=d*I+p*F+m*G+v*E,n[14]=d*C+p*N+m*J+v*T,n[3]=g*S+_*A+w*V+y*Y,n[7]=g*R+_*O+w*k+y*q,n[11]=g*I+_*F+w*G+y*E,n[15]=g*C+_*N+w*J+y*T,this},multiplyScalar:function(e){var t=this.elements;return t[0]*=e,t[4]*=e,t[8]*=e,t[12]*=e,t[1]*=e,t[5]*=e,t[9]*=e,t[13]*=e,t[2]*=e,t[6]*=e,t[10]*=e,t[14]*=e,t[3]*=e,t[7]*=e,t[11]*=e,t[15]*=e,this},applyToBufferAttribute:function(){var e=new b;return function(r){for(var i=0,n=r.count;i<n;i++)e.x=r.getX(i),e.y=r.getY(i),e.z=r.getZ(i),e.applyMatrix4(this),r.setXYZ(i,e.x,e.y,e.z);return r}}(),determinant:function(){var e=this.elements,t=e[0],r=e[4],i=e[8],n=e[12],a=e[1],s=e[5],o=e[9],h=e[13],c=e[2],u=e[6],l=e[10],f=e[14],d=e[3],p=e[7],m=e[11],v=e[15];return d*(+n*o*u-i*h*u-n*s*l+r*h*l+i*s*f-r*o*f)+p*(+t*o*f-t*h*l+n*a*l-i*a*f+i*h*c-n*o*c)+m*(+t*h*u-t*s*f-n*a*u+r*a*f+n*s*c-r*h*c)+v*(-i*s*c-t*o*u+t*s*l+i*a*u-r*a*l+r*o*c)},transpose:function(){var e=this.elements,t;return t=e[1],e[1]=e[4],e[4]=t,t=e[2],e[2]=e[8],e[8]=t,t=e[6],e[6]=e[9],e[9]=t,t=e[3],e[3]=e[12],e[12]=t,t=e[7],e[7]=e[13],e[13]=t,t=e[11],e[11]=e[14],e[14]=t,this},setPosition:function(e){var t=this.elements;return t[12]=e.x,t[13]=e.y,t[14]=e.z,this},getInverse:function(e,t){var r=this.elements,i=e.elements,n=i[0],a=i[1],s=i[2],o=i[3],h=i[4],c=i[5],u=i[6],l=i[7],f=i[8],d=i[9],p=i[10],m=i[11],v=i[12],g=i[13],_=i[14],w=i[15],y=d*_*l-g*p*l+g*u*m-c*_*m-d*u*w+c*p*w,S=v*p*l-f*_*l-v*u*m+h*_*m+f*u*w-h*p*w,R=f*g*l-v*d*l+v*c*m-h*g*m-f*c*w+h*d*w,I=v*d*u-f*g*u-v*c*p+h*g*p+f*c*_-h*d*_,C=n*y+a*S+s*R+o*I;if(C===0){var A="THREE.Matrix4: .getInverse() can't invert matrix, determinant is 0";if(t===!0)throw new Error(A);return console.warn(A),this.identity()}var O=1/C;return r[0]=y*O,r[1]=(g*p*o-d*_*o-g*s*m+a*_*m+d*s*w-a*p*w)*O,r[2]=(c*_*o-g*u*o+g*s*l-a*_*l-c*s*w+a*u*w)*O,r[3]=(d*u*o-c*p*o-d*s*l+a*p*l+c*s*m-a*u*m)*O,r[4]=S*O,r[5]=(f*_*o-v*p*o+v*s*m-n*_*m-f*s*w+n*p*w)*O,r[6]=(v*u*o-h*_*o-v*s*l+n*_*l+h*s*w-n*u*w)*O,r[7]=(h*p*o-f*u*o+f*s*l-n*p*l-h*s*m+n*u*m)*O,r[8]=R*O,r[9]=(v*d*o-f*g*o-v*a*m+n*g*m+f*a*w-n*d*w)*O,r[10]=(h*g*o-v*c*o+v*a*l-n*g*l-h*a*w+n*c*w)*O,r[11]=(f*c*o-h*d*o-f*a*l+n*d*l+h*a*m-n*c*m)*O,r[12]=I*O,r[13]=(f*g*s-v*d*s+v*a*p-n*g*p-f*a*_+n*d*_)*O,r[14]=(v*c*s-h*g*s-v*a*u+n*g*u+h*a*_-n*c*_)*O,r[15]=(h*d*s-f*c*s+f*a*u-n*d*u-h*a*p+n*c*p)*O,this},scale:function(e){var t=this.elements,r=e.x,i=e.y,n=e.z;return t[0]*=r,t[4]*=i,t[8]*=n,t[1]*=r,t[5]*=i,t[9]*=n,t[2]*=r,t[6]*=i,t[10]*=n,t[3]*=r,t[7]*=i,t[11]*=n,this},getMaxScaleOnAxis:function(){var e=this.elements,t=e[0]*e[0]+e[1]*e[1]+e[2]*e[2],r=e[4]*e[4]+e[5]*e[5]+e[6]*e[6],i=e[8]*e[8]+e[9]*e[9]+e[10]*e[10];return Math.sqrt(Math.max(t,r,i))},makeTranslation:function(e,t,r){return this.set(1,0,0,e,0,1,0,t,0,0,1,r,0,0,0,1),this},makeRotationX:function(e){var t=Math.cos(e),r=Math.sin(e);return this.set(1,0,0,0,0,t,-r,0,0,r,t,0,0,0,0,1),this},makeRotationY:function(e){var t=Math.cos(e),r=Math.sin(e);return this.set(t,0,r,0,0,1,0,0,-r,0,t,0,0,0,0,1),this},makeRotationZ:function(e){var t=Math.cos(e),r=Math.sin(e);return this.set(t,-r,0,0,r,t,0,0,0,0,1,0,0,0,0,1),this},makeRotationAxis:function(e,t){var r=Math.cos(t),i=Math.sin(t),n=1-r,a=e.x,s=e.y,o=e.z,h=n*a,c=n*s;return this.set(h*a+r,h*s-i*o,h*o+i*s,0,h*s+i*o,c*s+r,c*o-i*a,0,h*o-i*s,c*o+i*a,n*o*o+r,0,0,0,0,1),this},makeScale:function(e,t,r){return this.set(e,0,0,0,0,t,0,0,0,0,r,0,0,0,0,1),this},makeShear:function(e,t,r){return this.set(1,t,r,0,e,1,r,0,e,t,1,0,0,0,0,1),this},compose:function(e,t,r){var i=this.elements,n=t._x,a=t._y,s=t._z,o=t._w,h=n+n,c=a+a,u=s+s,l=n*h,f=n*c,d=n*u,p=a*c,m=a*u,v=s*u,g=o*h,_=o*c,w=o*u,y=r.x,S=r.y,R=r.z;return i[0]=(1-(p+v))*y,i[1]=(f+w)*y,i[2]=(d-_)*y,i[3]=0,i[4]=(f-w)*S,i[5]=(1-(l+v))*S,i[6]=(m+g)*S,i[7]=0,i[8]=(d+_)*R,i[9]=(m-g)*R,i[10]=(1-(l+p))*R,i[11]=0,i[12]=e.x,i[13]=e.y,i[14]=e.z,i[15]=1,this},decompose:function(){var e=new b,t=new fe;return function(i,n,a){var s=this.elements,o=e.set(s[0],s[1],s[2]).length(),h=e.set(s[4],s[5],s[6]).length(),c=e.set(s[8],s[9],s[10]).length(),u=this.determinant();u<0&&(o=-o),i.x=s[12],i.y=s[13],i.z=s[14],t.copy(this);var l=1/o,f=1/h,d=1/c;return t.elements[0]*=l,t.elements[1]*=l,t.elements[2]*=l,t.elements[4]*=f,t.elements[5]*=f,t.elements[6]*=f,t.elements[8]*=d,t.elements[9]*=d,t.elements[10]*=d,n.setFromRotationMatrix(t),a.x=o,a.y=h,a.z=c,this}}(),makePerspective:function(e,t,r,i,n,a){a===void 0&&console.warn("THREE.Matrix4: .makePerspective() has been redefined and has a new signature. Please check the docs.");var s=this.elements,o=2*n/(t-e),h=2*n/(r-i),c=(t+e)/(t-e),u=(r+i)/(r-i),l=-(a+n)/(a-n),f=-2*a*n/(a-n);return s[0]=o,s[4]=0,s[8]=c,s[12]=0,s[1]=0,s[5]=h,s[9]=u,s[13]=0,s[2]=0,s[6]=0,s[10]=l,s[14]=f,s[3]=0,s[7]=0,s[11]=-1,s[15]=0,this},makeOrthographic:function(e,t,r,i,n,a){var s=this.elements,o=1/(t-e),h=1/(r-i),c=1/(a-n),u=(t+e)*o,l=(r+i)*h,f=(a+n)*c;return s[0]=2*o,s[4]=0,s[8]=0,s[12]=-u,s[1]=0,s[5]=2*h,s[9]=0,s[13]=-l,s[2]=0,s[6]=0,s[10]=-2*c,s[14]=-f,s[3]=0,s[7]=0,s[11]=0,s[15]=1,this},equals:function(e){for(var t=this.elements,r=e.elements,i=0;i<16;i++)if(t[i]!==r[i])return!1;return!0},fromArray:function(e,t){t===void 0&&(t=0);for(var r=0;r<16;r++)this.elements[r]=e[r+t];return this},toArray:function(e,t){e===void 0&&(e=[]),t===void 0&&(t=0);var r=this.elements;return e[t]=r[0],e[t+1]=r[1],e[t+2]=r[2],e[t+3]=r[3],e[t+4]=r[4],e[t+5]=r[5],e[t+6]=r[6],e[t+7]=r[7],e[t+8]=r[8],e[t+9]=r[9],e[t+10]=r[10],e[t+11]=r[11],e[t+12]=r[12],e[t+13]=r[13],e[t+14]=r[14],e[t+15]=r[15],e}});function Qe(e,t,r,i){this._x=e||0,this._y=t||0,this._z=r||0,this._w=i!==void 0?i:1}Object.assign(Qe,{slerp:function(e,t,r,i){return r.copy(e).slerp(t,i)},slerpFlat:function(e,t,r,i,n,a,s){var o=r[i+0],h=r[i+1],c=r[i+2],u=r[i+3],l=n[a+0],f=n[a+1],d=n[a+2],p=n[a+3];if(u!==p||o!==l||h!==f||c!==d){var m=1-s,v=o*l+h*f+c*d+u*p,g=v>=0?1:-1,_=1-v*v;if(_>Number.EPSILON){var w=Math.sqrt(_),y=Math.atan2(w,v*g);m=Math.sin(m*y)/w,s=Math.sin(s*y)/w}var S=s*g;if(o=o*m+l*S,h=h*m+f*S,c=c*m+d*S,u=u*m+p*S,m===1-s){var R=1/Math.sqrt(o*o+h*h+c*c+u*u);o*=R,h*=R,c*=R,u*=R}}e[t]=o,e[t+1]=h,e[t+2]=c,e[t+3]=u}});Object.defineProperties(Qe.prototype,{x:{get:function(){return this._x},set:function(e){this._x=e,this.onChangeCallback()}},y:{get:function(){return this._y},set:function(e){this._y=e,this.onChangeCallback()}},z:{get:function(){return this._z},set:function(e){this._z=e,this.onChangeCallback()}},w:{get:function(){return this._w},set:function(e){this._w=e,this.onChangeCallback()}}});Object.assign(Qe.prototype,{isQuaternion:!0,set:function(e,t,r,i){return this._x=e,this._y=t,this._z=r,this._w=i,this.onChangeCallback(),this},clone:function(){return new this.constructor(this._x,this._y,this._z,this._w)},copy:function(e){return this._x=e.x,this._y=e.y,this._z=e.z,this._w=e.w,this.onChangeCallback(),this},setFromEuler:function(e,t){if(!(e&&e.isEuler))throw new Error("THREE.Quaternion: .setFromEuler() now expects an Euler rotation rather than a Vector3 and order.");var r=e._x,i=e._y,n=e._z,a=e.order,s=Math.cos,o=Math.sin,h=s(r/2),c=s(i/2),u=s(n/2),l=o(r/2),f=o(i/2),d=o(n/2);return a==="XYZ"?(this._x=l*c*u+h*f*d,this._y=h*f*u-l*c*d,this._z=h*c*d+l*f*u,this._w=h*c*u-l*f*d):a==="YXZ"?(this._x=l*c*u+h*f*d,this._y=h*f*u-l*c*d,this._z=h*c*d-l*f*u,this._w=h*c*u+l*f*d):a==="ZXY"?(this._x=l*c*u-h*f*d,this._y=h*f*u+l*c*d,this._z=h*c*d+l*f*u,this._w=h*c*u-l*f*d):a==="ZYX"?(this._x=l*c*u-h*f*d,this._y=h*f*u+l*c*d,this._z=h*c*d-l*f*u,this._w=h*c*u+l*f*d):a==="YZX"?(this._x=l*c*u+h*f*d,this._y=h*f*u+l*c*d,this._z=h*c*d-l*f*u,this._w=h*c*u-l*f*d):a==="XZY"&&(this._x=l*c*u-h*f*d,this._y=h*f*u-l*c*d,this._z=h*c*d+l*f*u,this._w=h*c*u+l*f*d),t!==!1&&this.onChangeCallback(),this},setFromAxisAngle:function(e,t){var r=t/2,i=Math.sin(r);return this._x=e.x*i,this._y=e.y*i,this._z=e.z*i,this._w=Math.cos(r),this.onChangeCallback(),this},setFromRotationMatrix:function(e){var t=e.elements,r=t[0],i=t[4],n=t[8],a=t[1],s=t[5],o=t[9],h=t[2],c=t[6],u=t[10],l=r+s+u,f;return l>0?(f=.5/Math.sqrt(l+1),this._w=.25/f,this._x=(c-o)*f,this._y=(n-h)*f,this._z=(a-i)*f):r>s&&r>u?(f=2*Math.sqrt(1+r-s-u),this._w=(c-o)/f,this._x=.25*f,this._y=(i+a)/f,this._z=(n+h)/f):s>u?(f=2*Math.sqrt(1+s-r-u),this._w=(n-h)/f,this._x=(i+a)/f,this._y=.25*f,this._z=(o+c)/f):(f=2*Math.sqrt(1+u-r-s),this._w=(a-i)/f,this._x=(n+h)/f,this._y=(o+c)/f,this._z=.25*f),this.onChangeCallback(),this},setFromUnitVectors:function(){var e=new b,t,r=1e-6;return function(n,a){return e===void 0&&(e=new b),t=n.dot(a)+1,t<r?(t=0,Math.abs(n.x)>Math.abs(n.z)?e.set(-n.y,n.x,0):e.set(0,-n.z,n.y)):e.crossVectors(n,a),this._x=e.x,this._y=e.y,this._z=e.z,this._w=t,this.normalize()}}(),angleTo:function(e){return 2*Math.acos(Math.abs(ge.clamp(this.dot(e),-1,1)))},rotateTowards:function(e,t){var r=this.angleTo(e);if(r===0)return this;var i=Math.min(1,t/r);return this.slerp(e,i),this},inverse:function(){return this.conjugate()},conjugate:function(){return this._x*=-1,this._y*=-1,this._z*=-1,this.onChangeCallback(),this},dot:function(e){return this._x*e._x+this._y*e._y+this._z*e._z+this._w*e._w},lengthSq:function(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w},length:function(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)},normalize:function(){var e=this.length();return e===0?(this._x=0,this._y=0,this._z=0,this._w=1):(e=1/e,this._x=this._x*e,this._y=this._y*e,this._z=this._z*e,this._w=this._w*e),this.onChangeCallback(),this},multiply:function(e,t){return t!==void 0?(console.warn("THREE.Quaternion: .multiply() now only accepts one argument. Use .multiplyQuaternions( a, b ) instead."),this.multiplyQuaternions(e,t)):this.multiplyQuaternions(this,e)},premultiply:function(e){return this.multiplyQuaternions(e,this)},multiplyQuaternions:function(e,t){var r=e._x,i=e._y,n=e._z,a=e._w,s=t._x,o=t._y,h=t._z,c=t._w;return this._x=r*c+a*s+i*h-n*o,this._y=i*c+a*o+n*s-r*h,this._z=n*c+a*h+r*o-i*s,this._w=a*c-r*s-i*o-n*h,this.onChangeCallback(),this},slerp:function(e,t){if(t===0)return this;if(t===1)return this.copy(e);var r=this._x,i=this._y,n=this._z,a=this._w,s=a*e._w+r*e._x+i*e._y+n*e._z;if(s<0?(this._w=-e._w,this._x=-e._x,this._y=-e._y,this._z=-e._z,s=-s):this.copy(e),s>=1)return this._w=a,this._x=r,this._y=i,this._z=n,this;var o=1-s*s;if(o<=Number.EPSILON){var h=1-t;return this._w=h*a+t*this._w,this._x=h*r+t*this._x,this._y=h*i+t*this._y,this._z=h*n+t*this._z,this.normalize()}var c=Math.sqrt(o),u=Math.atan2(c,s),l=Math.sin((1-t)*u)/c,f=Math.sin(t*u)/c;return this._w=a*l+this._w*f,this._x=r*l+this._x*f,this._y=i*l+this._y*f,this._z=n*l+this._z*f,this.onChangeCallback(),this},equals:function(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._w===this._w},fromArray:function(e,t){return t===void 0&&(t=0),this._x=e[t],this._y=e[t+1],this._z=e[t+2],this._w=e[t+3],this.onChangeCallback(),this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._w,e},onChange:function(e){return this.onChangeCallback=e,this},onChangeCallback:function(){}});function b(e,t,r){this.x=e||0,this.y=t||0,this.z=r||0}Object.assign(b.prototype,{isVector3:!0,set:function(e,t,r){return this.x=e,this.y=t,this.z=r,this},setScalar:function(e){return this.x=e,this.y=e,this.z=e,this},setX:function(e){return this.x=e,this},setY:function(e){return this.y=e,this},setZ:function(e){return this.z=e,this},setComponent:function(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;default:throw new Error("index is out of range: "+e)}return this},getComponent:function(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+e)}},clone:function(){return new this.constructor(this.x,this.y,this.z)},copy:function(e){return this.x=e.x,this.y=e.y,this.z=e.z,this},add:function(e,t){return t!==void 0?(console.warn("THREE.Vector3: .add() now only accepts one argument. Use .addVectors( a, b ) instead."),this.addVectors(e,t)):(this.x+=e.x,this.y+=e.y,this.z+=e.z,this)},addScalar:function(e){return this.x+=e,this.y+=e,this.z+=e,this},addVectors:function(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this},addScaledVector:function(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this},sub:function(e,t){return t!==void 0?(console.warn("THREE.Vector3: .sub() now only accepts one argument. Use .subVectors( a, b ) instead."),this.subVectors(e,t)):(this.x-=e.x,this.y-=e.y,this.z-=e.z,this)},subScalar:function(e){return this.x-=e,this.y-=e,this.z-=e,this},subVectors:function(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this},multiply:function(e,t){return t!==void 0?(console.warn("THREE.Vector3: .multiply() now only accepts one argument. Use .multiplyVectors( a, b ) instead."),this.multiplyVectors(e,t)):(this.x*=e.x,this.y*=e.y,this.z*=e.z,this)},multiplyScalar:function(e){return this.x*=e,this.y*=e,this.z*=e,this},multiplyVectors:function(e,t){return this.x=e.x*t.x,this.y=e.y*t.y,this.z=e.z*t.z,this},applyEuler:function(){var e=new Qe;return function(r){return r&&r.isEuler||console.error("THREE.Vector3: .applyEuler() now expects an Euler rotation rather than a Vector3 and order."),this.applyQuaternion(e.setFromEuler(r))}}(),applyAxisAngle:function(){var e=new Qe;return function(r,i){return this.applyQuaternion(e.setFromAxisAngle(r,i))}}(),applyMatrix3:function(e){var t=this.x,r=this.y,i=this.z,n=e.elements;return this.x=n[0]*t+n[3]*r+n[6]*i,this.y=n[1]*t+n[4]*r+n[7]*i,this.z=n[2]*t+n[5]*r+n[8]*i,this},applyMatrix4:function(e){var t=this.x,r=this.y,i=this.z,n=e.elements,a=1/(n[3]*t+n[7]*r+n[11]*i+n[15]);return this.x=(n[0]*t+n[4]*r+n[8]*i+n[12])*a,this.y=(n[1]*t+n[5]*r+n[9]*i+n[13])*a,this.z=(n[2]*t+n[6]*r+n[10]*i+n[14])*a,this},applyQuaternion:function(e){var t=this.x,r=this.y,i=this.z,n=e.x,a=e.y,s=e.z,o=e.w,h=o*t+a*i-s*r,c=o*r+s*t-n*i,u=o*i+n*r-a*t,l=-n*t-a*r-s*i;return this.x=h*o+l*-n+c*-s-u*-a,this.y=c*o+l*-a+u*-n-h*-s,this.z=u*o+l*-s+h*-a-c*-n,this},project:function(e){return this.applyMatrix4(e.matrixWorldInverse).applyMatrix4(e.projectionMatrix)},unproject:function(){var e=new fe;return function(r){return this.applyMatrix4(e.getInverse(r.projectionMatrix)).applyMatrix4(r.matrixWorld)}}(),transformDirection:function(e){var t=this.x,r=this.y,i=this.z,n=e.elements;return this.x=n[0]*t+n[4]*r+n[8]*i,this.y=n[1]*t+n[5]*r+n[9]*i,this.z=n[2]*t+n[6]*r+n[10]*i,this.normalize()},divide:function(e){return this.x/=e.x,this.y/=e.y,this.z/=e.z,this},divideScalar:function(e){return this.multiplyScalar(1/e)},min:function(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this},max:function(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this},clamp:function(e,t){return this.x=Math.max(e.x,Math.min(t.x,this.x)),this.y=Math.max(e.y,Math.min(t.y,this.y)),this.z=Math.max(e.z,Math.min(t.z,this.z)),this},clampScalar:function(){var e=new b,t=new b;return function(i,n){return e.set(i,i,i),t.set(n,n,n),this.clamp(e,t)}}(),clampLength:function(e,t){var r=this.length();return this.divideScalar(r||1).multiplyScalar(Math.max(e,Math.min(t,r)))},floor:function(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this},ceil:function(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this},round:function(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this},roundToZero:function(){return this.x=this.x<0?Math.ceil(this.x):Math.floor(this.x),this.y=this.y<0?Math.ceil(this.y):Math.floor(this.y),this.z=this.z<0?Math.ceil(this.z):Math.floor(this.z),this},negate:function(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this},dot:function(e){return this.x*e.x+this.y*e.y+this.z*e.z},lengthSq:function(){return this.x*this.x+this.y*this.y+this.z*this.z},length:function(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)},manhattanLength:function(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)},normalize:function(){return this.divideScalar(this.length()||1)},setLength:function(e){return this.normalize().multiplyScalar(e)},lerp:function(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this},lerpVectors:function(e,t,r){return this.subVectors(t,e).multiplyScalar(r).add(e)},cross:function(e,t){return t!==void 0?(console.warn("THREE.Vector3: .cross() now only accepts one argument. Use .crossVectors( a, b ) instead."),this.crossVectors(e,t)):this.crossVectors(this,e)},crossVectors:function(e,t){var r=e.x,i=e.y,n=e.z,a=t.x,s=t.y,o=t.z;return this.x=i*o-n*s,this.y=n*a-r*o,this.z=r*s-i*a,this},projectOnVector:function(e){var t=e.dot(this)/e.lengthSq();return this.copy(e).multiplyScalar(t)},projectOnPlane:function(){var e=new b;return function(r){return e.copy(this).projectOnVector(r),this.sub(e)}}(),reflect:function(){var e=new b;return function(r){return this.sub(e.copy(r).multiplyScalar(2*this.dot(r)))}}(),angleTo:function(e){var t=this.dot(e)/Math.sqrt(this.lengthSq()*e.lengthSq());return Math.acos(ge.clamp(t,-1,1))},distanceTo:function(e){return Math.sqrt(this.distanceToSquared(e))},distanceToSquared:function(e){var t=this.x-e.x,r=this.y-e.y,i=this.z-e.z;return t*t+r*r+i*i},manhattanDistanceTo:function(e){return Math.abs(this.x-e.x)+Math.abs(this.y-e.y)+Math.abs(this.z-e.z)},setFromSpherical:function(e){return this.setFromSphericalCoords(e.radius,e.phi,e.theta)},setFromSphericalCoords:function(e,t,r){var i=Math.sin(t)*e;return this.x=i*Math.sin(r),this.y=Math.cos(t)*e,this.z=i*Math.cos(r),this},setFromCylindrical:function(e){return this.setFromCylindricalCoords(e.radius,e.theta,e.y)},setFromCylindricalCoords:function(e,t,r){return this.x=e*Math.sin(t),this.y=r,this.z=e*Math.cos(t),this},setFromMatrixPosition:function(e){var t=e.elements;return this.x=t[12],this.y=t[13],this.z=t[14],this},setFromMatrixScale:function(e){var t=this.setFromMatrixColumn(e,0).length(),r=this.setFromMatrixColumn(e,1).length(),i=this.setFromMatrixColumn(e,2).length();return this.x=t,this.y=r,this.z=i,this},setFromMatrixColumn:function(e,t){return this.fromArray(e.elements,t*4)},equals:function(e){return e.x===this.x&&e.y===this.y&&e.z===this.z},fromArray:function(e,t){return t===void 0&&(t=0),this.x=e[t],this.y=e[t+1],this.z=e[t+2],this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e},fromBufferAttribute:function(e,t,r){return r!==void 0&&console.warn("THREE.Vector3: offset has been removed from .fromBufferAttribute()."),this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this}});function nt(){this.elements=[1,0,0,0,1,0,0,0,1],arguments.length>0&&console.error("THREE.Matrix3: the constructor no longer reads arguments. use .set() instead.")}Object.assign(nt.prototype,{isMatrix3:!0,set:function(e,t,r,i,n,a,s,o,h){var c=this.elements;return c[0]=e,c[1]=i,c[2]=s,c[3]=t,c[4]=n,c[5]=o,c[6]=r,c[7]=a,c[8]=h,this},identity:function(){return this.set(1,0,0,0,1,0,0,0,1),this},clone:function(){return new this.constructor().fromArray(this.elements)},copy:function(e){var t=this.elements,r=e.elements;return t[0]=r[0],t[1]=r[1],t[2]=r[2],t[3]=r[3],t[4]=r[4],t[5]=r[5],t[6]=r[6],t[7]=r[7],t[8]=r[8],this},setFromMatrix4:function(e){var t=e.elements;return this.set(t[0],t[4],t[8],t[1],t[5],t[9],t[2],t[6],t[10]),this},applyToBufferAttribute:function(){var e=new b;return function(r){for(var i=0,n=r.count;i<n;i++)e.x=r.getX(i),e.y=r.getY(i),e.z=r.getZ(i),e.applyMatrix3(this),r.setXYZ(i,e.x,e.y,e.z);return r}}(),multiply:function(e){return this.multiplyMatrices(this,e)},premultiply:function(e){return this.multiplyMatrices(e,this)},multiplyMatrices:function(e,t){var r=e.elements,i=t.elements,n=this.elements,a=r[0],s=r[3],o=r[6],h=r[1],c=r[4],u=r[7],l=r[2],f=r[5],d=r[8],p=i[0],m=i[3],v=i[6],g=i[1],_=i[4],w=i[7],y=i[2],S=i[5],R=i[8];return n[0]=a*p+s*g+o*y,n[3]=a*m+s*_+o*S,n[6]=a*v+s*w+o*R,n[1]=h*p+c*g+u*y,n[4]=h*m+c*_+u*S,n[7]=h*v+c*w+u*R,n[2]=l*p+f*g+d*y,n[5]=l*m+f*_+d*S,n[8]=l*v+f*w+d*R,this},multiplyScalar:function(e){var t=this.elements;return t[0]*=e,t[3]*=e,t[6]*=e,t[1]*=e,t[4]*=e,t[7]*=e,t[2]*=e,t[5]*=e,t[8]*=e,this},determinant:function(){var e=this.elements,t=e[0],r=e[1],i=e[2],n=e[3],a=e[4],s=e[5],o=e[6],h=e[7],c=e[8];return t*a*c-t*s*h-r*n*c+r*s*o+i*n*h-i*a*o},getInverse:function(e,t){e&&e.isMatrix4&&console.error("THREE.Matrix3: .getInverse() no longer takes a Matrix4 argument.");var r=e.elements,i=this.elements,n=r[0],a=r[1],s=r[2],o=r[3],h=r[4],c=r[5],u=r[6],l=r[7],f=r[8],d=f*h-c*l,p=c*u-f*o,m=l*o-h*u,v=n*d+a*p+s*m;if(v===0){var g="THREE.Matrix3: .getInverse() can't invert matrix, determinant is 0";if(t===!0)throw new Error(g);return console.warn(g),this.identity()}var _=1/v;return i[0]=d*_,i[1]=(s*l-f*a)*_,i[2]=(c*a-s*h)*_,i[3]=p*_,i[4]=(f*n-s*u)*_,i[5]=(s*o-c*n)*_,i[6]=m*_,i[7]=(a*u-l*n)*_,i[8]=(h*n-a*o)*_,this},transpose:function(){var e,t=this.elements;return e=t[1],t[1]=t[3],t[3]=e,e=t[2],t[2]=t[6],t[6]=e,e=t[5],t[5]=t[7],t[7]=e,this},getNormalMatrix:function(e){return this.setFromMatrix4(e).getInverse(this).transpose()},transposeIntoArray:function(e){var t=this.elements;return e[0]=t[0],e[1]=t[3],e[2]=t[6],e[3]=t[1],e[4]=t[4],e[5]=t[7],e[6]=t[2],e[7]=t[5],e[8]=t[8],this},setUvTransform:function(e,t,r,i,n,a,s){var o=Math.cos(n),h=Math.sin(n);this.set(r*o,r*h,-r*(o*a+h*s)+a+e,-i*h,i*o,-i*(-h*a+o*s)+s+t,0,0,1)},scale:function(e,t){var r=this.elements;return r[0]*=e,r[3]*=e,r[6]*=e,r[1]*=t,r[4]*=t,r[7]*=t,this},rotate:function(e){var t=Math.cos(e),r=Math.sin(e),i=this.elements,n=i[0],a=i[3],s=i[6],o=i[1],h=i[4],c=i[7];return i[0]=t*n+r*o,i[3]=t*a+r*h,i[6]=t*s+r*c,i[1]=-r*n+t*o,i[4]=-r*a+t*h,i[7]=-r*s+t*c,this},translate:function(e,t){var r=this.elements;return r[0]+=e*r[2],r[3]+=e*r[5],r[6]+=e*r[8],r[1]+=t*r[2],r[4]+=t*r[5],r[7]+=t*r[8],this},equals:function(e){for(var t=this.elements,r=e.elements,i=0;i<9;i++)if(t[i]!==r[i])return!1;return!0},fromArray:function(e,t){t===void 0&&(t=0);for(var r=0;r<9;r++)this.elements[r]=e[r+t];return this},toArray:function(e,t){e===void 0&&(e=[]),t===void 0&&(t=0);var r=this.elements;return e[t]=r[0],e[t+1]=r[1],e[t+2]=r[2],e[t+3]=r[3],e[t+4]=r[4],e[t+5]=r[5],e[t+6]=r[6],e[t+7]=r[7],e[t+8]=r[8],e}});var yr,ur={getDataURL:function(e){var t;if(typeof HTMLCanvasElement>"u")return e.src;if(e instanceof HTMLCanvasElement)t=e;else{yr===void 0&&(yr=document.createElementNS("http://www.w3.org/1999/xhtml","canvas")),yr.width=e.width,yr.height=e.height;var r=yr.getContext("2d");e instanceof ImageData?r.putImageData(e,0,0):r.drawImage(e,0,0,e.width,e.height),t=yr}return t.width>2048||t.height>2048?t.toDataURL("image/jpeg",.6):t.toDataURL("image/png")}},lc=0;function Ue(e,t,r,i,n,a,s,o,h,c){Object.defineProperty(this,"id",{value:lc++}),this.uuid=ge.generateUUID(),this.name="",this.image=e!==void 0?e:Ue.DEFAULT_IMAGE,this.mipmaps=[],this.mapping=t!==void 0?t:Ue.DEFAULT_MAPPING,this.wrapS=r!==void 0?r:Et,this.wrapT=i!==void 0?i:Et,this.magFilter=n!==void 0?n:it,this.minFilter=a!==void 0?a:Vn,this.anisotropy=h!==void 0?h:1,this.format=s!==void 0?s:Wt,this.type=o!==void 0?o:kn,this.offset=new z(0,0),this.repeat=new z(1,1),this.center=new z(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new nt,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,this.encoding=c!==void 0?c:$i,this.version=0,this.onUpdate=null}Ue.DEFAULT_IMAGE=void 0;Ue.DEFAULT_MAPPING=ka;Ue.prototype=Object.assign(Object.create(ar.prototype),{constructor:Ue,isTexture:!0,updateMatrix:function(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.name=e.name,this.image=e.image,this.mipmaps=e.mipmaps.slice(0),this.mapping=e.mapping,this.wrapS=e.wrapS,this.wrapT=e.wrapT,this.magFilter=e.magFilter,this.minFilter=e.minFilter,this.anisotropy=e.anisotropy,this.format=e.format,this.type=e.type,this.offset.copy(e.offset),this.repeat.copy(e.repeat),this.center.copy(e.center),this.rotation=e.rotation,this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrix.copy(e.matrix),this.generateMipmaps=e.generateMipmaps,this.premultiplyAlpha=e.premultiplyAlpha,this.flipY=e.flipY,this.unpackAlignment=e.unpackAlignment,this.encoding=e.encoding,this},toJSON:function(e){var t=e===void 0||typeof e=="string";if(!t&&e.textures[this.uuid]!==void 0)return e.textures[this.uuid];var r={metadata:{version:4.5,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,mapping:this.mapping,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,type:this.type,encoding:this.encoding,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};if(this.image!==void 0){var i=this.image;if(i.uuid===void 0&&(i.uuid=ge.generateUUID()),!t&&e.images[i.uuid]===void 0){var n;if(Array.isArray(i)){n=[];for(var a=0,s=i.length;a<s;a++)n.push(ur.getDataURL(i[a]))}else n=ur.getDataURL(i);e.images[i.uuid]={uuid:i.uuid,url:n}}r.image=i.uuid}return t||(e.textures[this.uuid]=r),r},dispose:function(){this.dispatchEvent({type:"dispose"})},transformUv:function(e){if(this.mapping!==ka)return e;if(e.applyMatrix3(this.matrix),e.x<0||e.x>1)switch(this.wrapS){case Qt:e.x=e.x-Math.floor(e.x);break;case Et:e.x=e.x<0?0:1;break;case Er:Math.abs(Math.floor(e.x)%2)===1?e.x=Math.ceil(e.x)-e.x:e.x=e.x-Math.floor(e.x);break}if(e.y<0||e.y>1)switch(this.wrapT){case Qt:e.y=e.y-Math.floor(e.y);break;case Et:e.y=e.y<0?0:1;break;case Er:Math.abs(Math.floor(e.y)%2)===1?e.y=Math.ceil(e.y)-e.y:e.y=e.y-Math.floor(e.y);break}return this.flipY&&(e.y=1-e.y),e}});Object.defineProperty(Ue.prototype,"needsUpdate",{set:function(e){e===!0&&this.version++}});function Fe(e,t,r,i){this.x=e||0,this.y=t||0,this.z=r||0,this.w=i!==void 0?i:1}Object.assign(Fe.prototype,{isVector4:!0,set:function(e,t,r,i){return this.x=e,this.y=t,this.z=r,this.w=i,this},setScalar:function(e){return this.x=e,this.y=e,this.z=e,this.w=e,this},setX:function(e){return this.x=e,this},setY:function(e){return this.y=e,this},setZ:function(e){return this.z=e,this},setW:function(e){return this.w=e,this},setComponent:function(e,t){switch(e){case 0:this.x=t;break;case 1:this.y=t;break;case 2:this.z=t;break;case 3:this.w=t;break;default:throw new Error("index is out of range: "+e)}return this},getComponent:function(e){switch(e){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+e)}},clone:function(){return new this.constructor(this.x,this.y,this.z,this.w)},copy:function(e){return this.x=e.x,this.y=e.y,this.z=e.z,this.w=e.w!==void 0?e.w:1,this},add:function(e,t){return t!==void 0?(console.warn("THREE.Vector4: .add() now only accepts one argument. Use .addVectors( a, b ) instead."),this.addVectors(e,t)):(this.x+=e.x,this.y+=e.y,this.z+=e.z,this.w+=e.w,this)},addScalar:function(e){return this.x+=e,this.y+=e,this.z+=e,this.w+=e,this},addVectors:function(e,t){return this.x=e.x+t.x,this.y=e.y+t.y,this.z=e.z+t.z,this.w=e.w+t.w,this},addScaledVector:function(e,t){return this.x+=e.x*t,this.y+=e.y*t,this.z+=e.z*t,this.w+=e.w*t,this},sub:function(e,t){return t!==void 0?(console.warn("THREE.Vector4: .sub() now only accepts one argument. Use .subVectors( a, b ) instead."),this.subVectors(e,t)):(this.x-=e.x,this.y-=e.y,this.z-=e.z,this.w-=e.w,this)},subScalar:function(e){return this.x-=e,this.y-=e,this.z-=e,this.w-=e,this},subVectors:function(e,t){return this.x=e.x-t.x,this.y=e.y-t.y,this.z=e.z-t.z,this.w=e.w-t.w,this},multiplyScalar:function(e){return this.x*=e,this.y*=e,this.z*=e,this.w*=e,this},applyMatrix4:function(e){var t=this.x,r=this.y,i=this.z,n=this.w,a=e.elements;return this.x=a[0]*t+a[4]*r+a[8]*i+a[12]*n,this.y=a[1]*t+a[5]*r+a[9]*i+a[13]*n,this.z=a[2]*t+a[6]*r+a[10]*i+a[14]*n,this.w=a[3]*t+a[7]*r+a[11]*i+a[15]*n,this},divideScalar:function(e){return this.multiplyScalar(1/e)},setAxisAngleFromQuaternion:function(e){this.w=2*Math.acos(e.w);var t=Math.sqrt(1-e.w*e.w);return t<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=e.x/t,this.y=e.y/t,this.z=e.z/t),this},setAxisAngleFromRotationMatrix:function(e){var t,r,i,n,a=.01,s=.1,o=e.elements,h=o[0],c=o[4],u=o[8],l=o[1],f=o[5],d=o[9],p=o[2],m=o[6],v=o[10];if(Math.abs(c-l)<a&&Math.abs(u-p)<a&&Math.abs(d-m)<a){if(Math.abs(c+l)<s&&Math.abs(u+p)<s&&Math.abs(d+m)<s&&Math.abs(h+f+v-3)<s)return this.set(1,0,0,0),this;t=Math.PI;var g=(h+1)/2,_=(f+1)/2,w=(v+1)/2,y=(c+l)/4,S=(u+p)/4,R=(d+m)/4;return g>_&&g>w?g<a?(r=0,i=.707106781,n=.707106781):(r=Math.sqrt(g),i=y/r,n=S/r):_>w?_<a?(r=.707106781,i=0,n=.707106781):(i=Math.sqrt(_),r=y/i,n=R/i):w<a?(r=.707106781,i=.707106781,n=0):(n=Math.sqrt(w),r=S/n,i=R/n),this.set(r,i,n,t),this}var I=Math.sqrt((m-d)*(m-d)+(u-p)*(u-p)+(l-c)*(l-c));return Math.abs(I)<.001&&(I=1),this.x=(m-d)/I,this.y=(u-p)/I,this.z=(l-c)/I,this.w=Math.acos((h+f+v-1)/2),this},min:function(e){return this.x=Math.min(this.x,e.x),this.y=Math.min(this.y,e.y),this.z=Math.min(this.z,e.z),this.w=Math.min(this.w,e.w),this},max:function(e){return this.x=Math.max(this.x,e.x),this.y=Math.max(this.y,e.y),this.z=Math.max(this.z,e.z),this.w=Math.max(this.w,e.w),this},clamp:function(e,t){return this.x=Math.max(e.x,Math.min(t.x,this.x)),this.y=Math.max(e.y,Math.min(t.y,this.y)),this.z=Math.max(e.z,Math.min(t.z,this.z)),this.w=Math.max(e.w,Math.min(t.w,this.w)),this},clampScalar:function(){var e,t;return function(i,n){return e===void 0&&(e=new Fe,t=new Fe),e.set(i,i,i,i),t.set(n,n,n,n),this.clamp(e,t)}}(),clampLength:function(e,t){var r=this.length();return this.divideScalar(r||1).multiplyScalar(Math.max(e,Math.min(t,r)))},floor:function(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this},ceil:function(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this},round:function(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this},roundToZero:function(){return this.x=this.x<0?Math.ceil(this.x):Math.floor(this.x),this.y=this.y<0?Math.ceil(this.y):Math.floor(this.y),this.z=this.z<0?Math.ceil(this.z):Math.floor(this.z),this.w=this.w<0?Math.ceil(this.w):Math.floor(this.w),this},negate:function(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this},dot:function(e){return this.x*e.x+this.y*e.y+this.z*e.z+this.w*e.w},lengthSq:function(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w},length:function(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)},manhattanLength:function(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)},normalize:function(){return this.divideScalar(this.length()||1)},setLength:function(e){return this.normalize().multiplyScalar(e)},lerp:function(e,t){return this.x+=(e.x-this.x)*t,this.y+=(e.y-this.y)*t,this.z+=(e.z-this.z)*t,this.w+=(e.w-this.w)*t,this},lerpVectors:function(e,t,r){return this.subVectors(t,e).multiplyScalar(r).add(e)},equals:function(e){return e.x===this.x&&e.y===this.y&&e.z===this.z&&e.w===this.w},fromArray:function(e,t){return t===void 0&&(t=0),this.x=e[t],this.y=e[t+1],this.z=e[t+2],this.w=e[t+3],this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this.x,e[t+1]=this.y,e[t+2]=this.z,e[t+3]=this.w,e},fromBufferAttribute:function(e,t,r){return r!==void 0&&console.warn("THREE.Vector4: offset has been removed from .fromBufferAttribute()."),this.x=e.getX(t),this.y=e.getY(t),this.z=e.getZ(t),this.w=e.getW(t),this}});function Dt(e,t,r){this.width=e,this.height=t,this.scissor=new Fe(0,0,e,t),this.scissorTest=!1,this.viewport=new Fe(0,0,e,t),r=r||{},this.texture=new Ue(void 0,void 0,r.wrapS,r.wrapT,r.magFilter,r.minFilter,r.format,r.type,r.anisotropy,r.encoding),this.texture.generateMipmaps=r.generateMipmaps!==void 0?r.generateMipmaps:!1,this.texture.minFilter=r.minFilter!==void 0?r.minFilter:it,this.depthBuffer=r.depthBuffer!==void 0?r.depthBuffer:!0,this.stencilBuffer=r.stencilBuffer!==void 0?r.stencilBuffer:!0,this.depthTexture=r.depthTexture!==void 0?r.depthTexture:null}Dt.prototype=Object.assign(Object.create(ar.prototype),{constructor:Dt,isWebGLRenderTarget:!0,setSize:function(e,t){(this.width!==e||this.height!==t)&&(this.width=e,this.height=t,this.dispose()),this.viewport.set(0,0,e,t),this.scissor.set(0,0,e,t)},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.width=e.width,this.height=e.height,this.viewport.copy(e.viewport),this.texture=e.texture.clone(),this.depthBuffer=e.depthBuffer,this.stencilBuffer=e.stencilBuffer,this.depthTexture=e.depthTexture,this},dispose:function(){this.dispatchEvent({type:"dispose"})}});function fs(e,t,r){Dt.call(this,e,t,r),this.samples=4}fs.prototype=Object.assign(Object.create(Dt.prototype),{constructor:fs,isWebGLMultisampleRenderTarget:!0,copy:function(e){return Dt.prototype.copy.call(this,e),this.samples=e.samples,this}});function ti(e,t,r){Dt.call(this,e,t,r),this.activeCubeFace=0,this.activeMipMapLevel=0}ti.prototype=Object.create(Dt.prototype);ti.prototype.constructor=ti;ti.prototype.isWebGLRenderTargetCube=!0;function Sr(e,t,r,i,n,a,s,o,h,c,u,l){Ue.call(this,null,a,s,o,h,c,i,n,u,l),this.image={data:e,width:t,height:r},this.magFilter=h!==void 0?h:et,this.minFilter=c!==void 0?c:et,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}Sr.prototype=Object.create(Ue.prototype);Sr.prototype.constructor=Sr;Sr.prototype.isDataTexture=!0;function tr(e,t){this.min=e!==void 0?e:new b(1/0,1/0,1/0),this.max=t!==void 0?t:new b(-1/0,-1/0,-1/0)}Object.assign(tr.prototype,{isBox3:!0,set:function(e,t){return this.min.copy(e),this.max.copy(t),this},setFromArray:function(e){for(var t=1/0,r=1/0,i=1/0,n=-1/0,a=-1/0,s=-1/0,o=0,h=e.length;o<h;o+=3){var c=e[o],u=e[o+1],l=e[o+2];c<t&&(t=c),u<r&&(r=u),l<i&&(i=l),c>n&&(n=c),u>a&&(a=u),l>s&&(s=l)}return this.min.set(t,r,i),this.max.set(n,a,s),this},setFromBufferAttribute:function(e){for(var t=1/0,r=1/0,i=1/0,n=-1/0,a=-1/0,s=-1/0,o=0,h=e.count;o<h;o++){var c=e.getX(o),u=e.getY(o),l=e.getZ(o);c<t&&(t=c),u<r&&(r=u),l<i&&(i=l),c>n&&(n=c),u>a&&(a=u),l>s&&(s=l)}return this.min.set(t,r,i),this.max.set(n,a,s),this},setFromPoints:function(e){this.makeEmpty();for(var t=0,r=e.length;t<r;t++)this.expandByPoint(e[t]);return this},setFromCenterAndSize:function(){var e=new b;return function(r,i){var n=e.copy(i).multiplyScalar(.5);return this.min.copy(r).sub(n),this.max.copy(r).add(n),this}}(),setFromObject:function(e){return this.makeEmpty(),this.expandByObject(e)},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.min.copy(e.min),this.max.copy(e.max),this},makeEmpty:function(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this},isEmpty:function(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z},getCenter:function(e){return e===void 0&&(console.warn("THREE.Box3: .getCenter() target is now required"),e=new b),this.isEmpty()?e.set(0,0,0):e.addVectors(this.min,this.max).multiplyScalar(.5)},getSize:function(e){return e===void 0&&(console.warn("THREE.Box3: .getSize() target is now required"),e=new b),this.isEmpty()?e.set(0,0,0):e.subVectors(this.max,this.min)},expandByPoint:function(e){return this.min.min(e),this.max.max(e),this},expandByVector:function(e){return this.min.sub(e),this.max.add(e),this},expandByScalar:function(e){return this.min.addScalar(-e),this.max.addScalar(e),this},expandByObject:function(){var e,t,r,i=new b;function n(a){var s=a.geometry;if(s!==void 0){if(s.isGeometry){var o=s.vertices;for(t=0,r=o.length;t<r;t++)i.copy(o[t]),i.applyMatrix4(a.matrixWorld),e.expandByPoint(i)}else if(s.isBufferGeometry){var h=s.attributes.position;if(h!==void 0)for(t=0,r=h.count;t<r;t++)i.fromBufferAttribute(h,t).applyMatrix4(a.matrixWorld),e.expandByPoint(i)}}}return function(s){return e=this,s.updateMatrixWorld(!0),s.traverse(n),this}}(),containsPoint:function(e){return!(e.x<this.min.x||e.x>this.max.x||e.y<this.min.y||e.y>this.max.y||e.z<this.min.z||e.z>this.max.z)},containsBox:function(e){return this.min.x<=e.min.x&&e.max.x<=this.max.x&&this.min.y<=e.min.y&&e.max.y<=this.max.y&&this.min.z<=e.min.z&&e.max.z<=this.max.z},getParameter:function(e,t){return t===void 0&&(console.warn("THREE.Box3: .getParameter() target is now required"),t=new b),t.set((e.x-this.min.x)/(this.max.x-this.min.x),(e.y-this.min.y)/(this.max.y-this.min.y),(e.z-this.min.z)/(this.max.z-this.min.z))},intersectsBox:function(e){return!(e.max.x<this.min.x||e.min.x>this.max.x||e.max.y<this.min.y||e.min.y>this.max.y||e.max.z<this.min.z||e.min.z>this.max.z)},intersectsSphere:function(){var e=new b;return function(r){return this.clampPoint(r.center,e),e.distanceToSquared(r.center)<=r.radius*r.radius}}(),intersectsPlane:function(e){var t,r;return e.normal.x>0?(t=e.normal.x*this.min.x,r=e.normal.x*this.max.x):(t=e.normal.x*this.max.x,r=e.normal.x*this.min.x),e.normal.y>0?(t+=e.normal.y*this.min.y,r+=e.normal.y*this.max.y):(t+=e.normal.y*this.max.y,r+=e.normal.y*this.min.y),e.normal.z>0?(t+=e.normal.z*this.min.z,r+=e.normal.z*this.max.z):(t+=e.normal.z*this.max.z,r+=e.normal.z*this.min.z),t<=-e.constant&&r>=-e.constant},intersectsTriangle:function(){var e=new b,t=new b,r=new b,i=new b,n=new b,a=new b,s=new b,o=new b,h=new b,c=new b;function u(l){var f,d;for(f=0,d=l.length-3;f<=d;f+=3){s.fromArray(l,f);var p=h.x*Math.abs(s.x)+h.y*Math.abs(s.y)+h.z*Math.abs(s.z),m=e.dot(s),v=t.dot(s),g=r.dot(s);if(Math.max(-Math.max(m,v,g),Math.min(m,v,g))>p)return!1}return!0}return function(f){if(this.isEmpty())return!1;this.getCenter(o),h.subVectors(this.max,o),e.subVectors(f.a,o),t.subVectors(f.b,o),r.subVectors(f.c,o),i.subVectors(t,e),n.subVectors(r,t),a.subVectors(e,r);var d=[0,-i.z,i.y,0,-n.z,n.y,0,-a.z,a.y,i.z,0,-i.x,n.z,0,-n.x,a.z,0,-a.x,-i.y,i.x,0,-n.y,n.x,0,-a.y,a.x,0];return!u(d)||(d=[1,0,0,0,1,0,0,0,1],!u(d))?!1:(c.crossVectors(i,n),d=[c.x,c.y,c.z],u(d))}}(),clampPoint:function(e,t){return t===void 0&&(console.warn("THREE.Box3: .clampPoint() target is now required"),t=new b),t.copy(e).clamp(this.min,this.max)},distanceToPoint:function(){var e=new b;return function(r){var i=e.copy(r).clamp(this.min,this.max);return i.sub(r).length()}}(),getBoundingSphere:function(){var e=new b;return function(r){return r===void 0&&(console.warn("THREE.Box3: .getBoundingSphere() target is now required"),r=new Ot),this.getCenter(r.center),r.radius=this.getSize(e).length()*.5,r}}(),intersect:function(e){return this.min.max(e.min),this.max.min(e.max),this.isEmpty()&&this.makeEmpty(),this},union:function(e){return this.min.min(e.min),this.max.max(e.max),this},applyMatrix4:function(){var e=[new b,new b,new b,new b,new b,new b,new b,new b];return function(r){return this.isEmpty()?this:(e[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(r),e[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(r),e[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(r),e[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(r),e[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(r),e[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(r),e[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(r),e[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(r),this.setFromPoints(e),this)}}(),translate:function(e){return this.min.add(e),this.max.add(e),this},equals:function(e){return e.min.equals(this.min)&&e.max.equals(this.max)}});function Ot(e,t){this.center=e!==void 0?e:new b,this.radius=t!==void 0?t:0}Object.assign(Ot.prototype,{set:function(e,t){return this.center.copy(e),this.radius=t,this},setFromPoints:function(){var e=new tr;return function(r,i){var n=this.center;i!==void 0?n.copy(i):e.setFromPoints(r).getCenter(n);for(var a=0,s=0,o=r.length;s<o;s++)a=Math.max(a,n.distanceToSquared(r[s]));return this.radius=Math.sqrt(a),this}}(),clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.center.copy(e.center),this.radius=e.radius,this},empty:function(){return this.radius<=0},containsPoint:function(e){return e.distanceToSquared(this.center)<=this.radius*this.radius},distanceToPoint:function(e){return e.distanceTo(this.center)-this.radius},intersectsSphere:function(e){var t=this.radius+e.radius;return e.center.distanceToSquared(this.center)<=t*t},intersectsBox:function(e){return e.intersectsSphere(this)},intersectsPlane:function(e){return Math.abs(e.distanceToPoint(this.center))<=this.radius},clampPoint:function(e,t){var r=this.center.distanceToSquared(e);return t===void 0&&(console.warn("THREE.Sphere: .clampPoint() target is now required"),t=new b),t.copy(e),r>this.radius*this.radius&&(t.sub(this.center).normalize(),t.multiplyScalar(this.radius).add(this.center)),t},getBoundingBox:function(e){return e===void 0&&(console.warn("THREE.Sphere: .getBoundingBox() target is now required"),e=new tr),e.set(this.center,this.center),e.expandByScalar(this.radius),e},applyMatrix4:function(e){return this.center.applyMatrix4(e),this.radius=this.radius*e.getMaxScaleOnAxis(),this},translate:function(e){return this.center.add(e),this},equals:function(e){return e.center.equals(this.center)&&e.radius===this.radius}});function Vt(e,t){this.normal=e!==void 0?e:new b(1,0,0),this.constant=t!==void 0?t:0}Object.assign(Vt.prototype,{set:function(e,t){return this.normal.copy(e),this.constant=t,this},setComponents:function(e,t,r,i){return this.normal.set(e,t,r),this.constant=i,this},setFromNormalAndCoplanarPoint:function(e,t){return this.normal.copy(e),this.constant=-t.dot(this.normal),this},setFromCoplanarPoints:function(){var e=new b,t=new b;return function(i,n,a){var s=e.subVectors(a,n).cross(t.subVectors(i,n)).normalize();return this.setFromNormalAndCoplanarPoint(s,i),this}}(),clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.normal.copy(e.normal),this.constant=e.constant,this},normalize:function(){var e=1/this.normal.length();return this.normal.multiplyScalar(e),this.constant*=e,this},negate:function(){return this.constant*=-1,this.normal.negate(),this},distanceToPoint:function(e){return this.normal.dot(e)+this.constant},distanceToSphere:function(e){return this.distanceToPoint(e.center)-e.radius},projectPoint:function(e,t){return t===void 0&&(console.warn("THREE.Plane: .projectPoint() target is now required"),t=new b),t.copy(this.normal).multiplyScalar(-this.distanceToPoint(e)).add(e)},intersectLine:function(){var e=new b;return function(r,i){i===void 0&&(console.warn("THREE.Plane: .intersectLine() target is now required"),i=new b);var n=r.delta(e),a=this.normal.dot(n);if(a===0)return this.distanceToPoint(r.start)===0?i.copy(r.start):void 0;var s=-(r.start.dot(this.normal)+this.constant)/a;if(!(s<0||s>1))return i.copy(n).multiplyScalar(s).add(r.start)}}(),intersectsLine:function(e){var t=this.distanceToPoint(e.start),r=this.distanceToPoint(e.end);return t<0&&r>0||r<0&&t>0},intersectsBox:function(e){return e.intersectsPlane(this)},intersectsSphere:function(e){return e.intersectsPlane(this)},coplanarPoint:function(e){return e===void 0&&(console.warn("THREE.Plane: .coplanarPoint() target is now required"),e=new b),e.copy(this.normal).multiplyScalar(-this.constant)},applyMatrix4:function(){var e=new b,t=new nt;return function(i,n){var a=n||t.getNormalMatrix(i),s=this.coplanarPoint(e).applyMatrix4(i),o=this.normal.applyMatrix3(a).normalize();return this.constant=-s.dot(o),this}}(),translate:function(e){return this.constant-=e.dot(this.normal),this},equals:function(e){return e.normal.equals(this.normal)&&e.constant===this.constant}});function Ja(e,t,r,i,n,a){this.planes=[e!==void 0?e:new Vt,t!==void 0?t:new Vt,r!==void 0?r:new Vt,i!==void 0?i:new Vt,n!==void 0?n:new Vt,a!==void 0?a:new Vt]}Object.assign(Ja.prototype,{set:function(e,t,r,i,n,a){var s=this.planes;return s[0].copy(e),s[1].copy(t),s[2].copy(r),s[3].copy(i),s[4].copy(n),s[5].copy(a),this},clone:function(){return new this.constructor().copy(this)},copy:function(e){for(var t=this.planes,r=0;r<6;r++)t[r].copy(e.planes[r]);return this},setFromMatrix:function(e){var t=this.planes,r=e.elements,i=r[0],n=r[1],a=r[2],s=r[3],o=r[4],h=r[5],c=r[6],u=r[7],l=r[8],f=r[9],d=r[10],p=r[11],m=r[12],v=r[13],g=r[14],_=r[15];return t[0].setComponents(s-i,u-o,p-l,_-m).normalize(),t[1].setComponents(s+i,u+o,p+l,_+m).normalize(),t[2].setComponents(s+n,u+h,p+f,_+v).normalize(),t[3].setComponents(s-n,u-h,p-f,_-v).normalize(),t[4].setComponents(s-a,u-c,p-d,_-g).normalize(),t[5].setComponents(s+a,u+c,p+d,_+g).normalize(),this},intersectsObject:function(){var e=new Ot;return function(r){var i=r.geometry;return i.boundingSphere===null&&i.computeBoundingSphere(),e.copy(i.boundingSphere).applyMatrix4(r.matrixWorld),this.intersectsSphere(e)}}(),intersectsSprite:function(){var e=new Ot;return function(r){return e.center.set(0,0,0),e.radius=.7071067811865476,e.applyMatrix4(r.matrixWorld),this.intersectsSphere(e)}}(),intersectsSphere:function(e){for(var t=this.planes,r=e.center,i=-e.radius,n=0;n<6;n++){var a=t[n].distanceToPoint(r);if(a<i)return!1}return!0},intersectsBox:function(){var e=new b;return function(r){for(var i=this.planes,n=0;n<6;n++){var a=i[n];if(e.x=a.normal.x>0?r.max.x:r.min.x,e.y=a.normal.y>0?r.max.y:r.min.y,e.z=a.normal.z>0?r.max.z:r.min.z,a.distanceToPoint(e)<0)return!1}return!0}}(),containsPoint:function(e){for(var t=this.planes,r=0;r<6;r++)if(t[r].distanceToPoint(e)<0)return!1;return!0}});const fc=`
#ifdef USE_ALPHAMAP

	diffuseColor.a *= texture2D( alphaMap, vUv ).g;

#endif
`,dc=`
#ifdef USE_ALPHAMAP

	uniform sampler2D alphaMap;

#endif
`,pc=`
#ifdef ALPHATEST

	if ( diffuseColor.a < ALPHATEST ) discard;

#endif
`,mc=`
#ifdef USE_AOMAP

	// reads channel R, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	float ambientOcclusion = ( texture2D( aoMap, vUv2 ).r - 1.0 ) * aoMapIntensity + 1.0;

	reflectedLight.indirectDiffuse *= ambientOcclusion;

	#if defined( USE_ENVMAP ) && defined( PHYSICAL )

		float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );

		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.specularRoughness );

	#endif

#endif
`,vc=`
#ifdef USE_AOMAP

	uniform sampler2D aoMap;
	uniform float aoMapIntensity;

#endif
`,gc=`
vec3 transformed = vec3( position );
`,yc=`
vec3 objectNormal = vec3( normal );
`,xc=`
float punctualLightIntensityToIrradianceFactor( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {

#if defined ( PHYSICALLY_CORRECT_LIGHTS )

	// based upon Frostbite 3 Moving to Physically-based Rendering
	// page 32, equation 26: E[window1]
	// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
	// this is intended to be used on spot and point lights who are represented as luminous intensity
	// but who must be converted to luminous irradiance for surface lighting calculation
	float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );

	if( cutoffDistance > 0.0 ) {

		distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );

	}

	return distanceFalloff;

#else

	if( cutoffDistance > 0.0 && decayExponent > 0.0 ) {

		return pow( saturate( -lightDistance / cutoffDistance + 1.0 ), decayExponent );

	}

	return 1.0;

#endif

}

vec3 BRDF_Diffuse_Lambert( const in vec3 diffuseColor ) {

	return RECIPROCAL_PI * diffuseColor;

} // validated

vec3 F_Schlick( const in vec3 specularColor, const in float dotLH ) {

	// Original approximation by Christophe Schlick '94
	// float fresnel = pow( 1.0 - dotLH, 5.0 );

	// Optimized variant (presented by Epic at SIGGRAPH '13)
	// https://cdn2.unrealengine.com/Resources/files/2013SiggraphPresentationsNotes-26915738.pdf
	float fresnel = exp2( ( -5.55473 * dotLH - 6.98316 ) * dotLH );

	return ( 1.0 - specularColor ) * fresnel + specularColor;

} // validated

// Microfacet Models for Refraction through Rough Surfaces - equation (34)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float G_GGX_Smith( const in float alpha, const in float dotNL, const in float dotNV ) {

	// geometry term (normalized) = G(l)⋅G(v) / 4(n⋅l)(n⋅v)
	// also see #12151

	float a2 = pow2( alpha );

	float gl = dotNL + sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	float gv = dotNV + sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );

	return 1.0 / ( gl * gv );

} // validated

// Moving Frostbite to Physically Based Rendering 3.0 - page 12, listing 2
// https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float G_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {

	float a2 = pow2( alpha );

	// dotNL and dotNV are explicitly swapped. This is not a mistake.
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );

	return 0.5 / max( gv + gl, EPSILON );

}

// Microfacet Models for Refraction through Rough Surfaces - equation (33)
// http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
// alpha is "roughness squared" in Disney’s reparameterization
float D_GGX( const in float alpha, const in float dotNH ) {

	float a2 = pow2( alpha );

	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0; // avoid alpha = 0 with dotNH = 1

	return RECIPROCAL_PI * a2 / pow2( denom );

}

// GGX Distribution, Schlick Fresnel, GGX-Smith Visibility
vec3 BRDF_Specular_GGX( const in IncidentLight incidentLight, const in GeometricContext geometry, const in vec3 specularColor, const in float roughness ) {

	float alpha = pow2( roughness ); // UE4's roughness

	vec3 halfDir = normalize( incidentLight.direction + geometry.viewDir );

	float dotNL = saturate( dot( geometry.normal, incidentLight.direction ) );
	float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
	float dotNH = saturate( dot( geometry.normal, halfDir ) );
	float dotLH = saturate( dot( incidentLight.direction, halfDir ) );

	vec3 F = F_Schlick( specularColor, dotLH );

	float G = G_GGX_SmithCorrelated( alpha, dotNL, dotNV );

	float D = D_GGX( alpha, dotNH );

	return F * ( G * D );

} // validated

// Rect Area Light

// Real-Time Polygonal-Light Shading with Linearly Transformed Cosines
// by Eric Heitz, Jonathan Dupuy, Stephen Hill and David Neubelt
// code: https://github.com/selfshadow/ltc_code/

vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {

	const float LUT_SIZE  = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS  = 0.5 / LUT_SIZE;

	float dotNV = saturate( dot( N, V ) );

	// texture parameterized by sqrt( GGX alpha ) and sqrt( 1 - cos( theta ) )
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );

	uv = uv * LUT_SCALE + LUT_BIAS;

	return uv;

}

float LTC_ClippedSphereFormFactor( const in vec3 f ) {

	// Real-Time Area Lighting: a Journey from Research to Production (p.102)
	// An approximation of the form factor of a horizon-clipped rectangle.

	float l = length( f );

	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );

}

vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {

	float x = dot( v1, v2 );

	float y = abs( x );

	// rational polynomial approximation to theta / sin( theta ) / 2PI
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;

	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;

	return cross( v1, v2 ) * theta_sintheta;

}

vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {

	// bail if point is on back side of plane of light
	// assumes ccw winding order of light vertices
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );

	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );

	// construct orthonormal basis around N
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 ); // negated from paper; possibly due to a different handedness of world coordinate system

	// compute transform
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );

	// transform rect
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );

	// project rect onto sphere
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );

	// calculate vector form factor
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );

	// adjust for horizon clipping
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );

/*
	// alternate method of adjusting for horizon clipping (see referece)
	// refactoring required
	float len = length( vectorFormFactor );
	float z = vectorFormFactor.z / len;

	const float LUT_SIZE  = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS  = 0.5 / LUT_SIZE;

	// tabulated horizon-clipped sphere, apparently...
	vec2 uv = vec2( z * 0.5 + 0.5, len );
	uv = uv * LUT_SCALE + LUT_BIAS;

	float scale = texture2D( ltc_2, uv ).w;

	float result = len * scale;
*/

	return vec3( result );

}

// End Rect Area Light

// ref: https://www.unrealengine.com/blog/physically-based-shading-on-mobile - environmentBRDF for GGX on mobile
vec3 BRDF_Specular_GGX_Environment( const in GeometricContext geometry, const in vec3 specularColor, const in float roughness ) {

	float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );

	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );

	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );

	vec4 r = roughness * c0 + c1;

	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;

	vec2 AB = vec2( -1.04, 1.04 ) * a004 + r.zw;

	return specularColor * AB.x + AB.y;

} // validated


float G_BlinnPhong_Implicit( /* const in float dotNL, const in float dotNV */ ) {

	// geometry term is (n dot l)(n dot v) / 4(n dot l)(n dot v)
	return 0.25;

}

float D_BlinnPhong( const in float shininess, const in float dotNH ) {

	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );

}

vec3 BRDF_Specular_BlinnPhong( const in IncidentLight incidentLight, const in GeometricContext geometry, const in vec3 specularColor, const in float shininess ) {

	vec3 halfDir = normalize( incidentLight.direction + geometry.viewDir );

	//float dotNL = saturate( dot( geometry.normal, incidentLight.direction ) );
	//float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
	float dotNH = saturate( dot( geometry.normal, halfDir ) );
	float dotLH = saturate( dot( incidentLight.direction, halfDir ) );

	vec3 F = F_Schlick( specularColor, dotLH );

	float G = G_BlinnPhong_Implicit( /* dotNL, dotNV */ );

	float D = D_BlinnPhong( shininess, dotNH );

	return F * ( G * D );

} // validated

// source: http://simonstechblog.blogspot.ca/2011/12/microfacet-brdf.html
float GGXRoughnessToBlinnExponent( const in float ggxRoughness ) {
	return ( 2.0 / pow2( ggxRoughness + 0.0001 ) - 2.0 );
}

float BlinnExponentToGGXRoughness( const in float blinnExponent ) {
	return sqrt( 2.0 / ( blinnExponent + 2.0 ) );
}
`,_c=`
#ifdef USE_BUMPMAP

	uniform sampler2D bumpMap;
	uniform float bumpScale;

	// Bump Mapping Unparametrized Surfaces on the GPU by Morten S. Mikkelsen
	// http://api.unrealengine.com/attachments/Engine/Rendering/LightingAndShadows/BumpMappingWithoutTangentSpace/mm_sfgrad_bump.pdf

	// Evaluate the derivative of the height w.r.t. screen-space using forward differencing (listing 2)

	vec2 dHdxy_fwd() {

		vec2 dSTdx = dFdx( vUv );
		vec2 dSTdy = dFdy( vUv );

		float Hll = bumpScale * texture2D( bumpMap, vUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vUv + dSTdy ).x - Hll;

		return vec2( dBx, dBy );

	}

	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy ) {

		// Workaround for Adreno 3XX dFd*( vec3 ) bug. See #9988

		vec3 vSigmaX = vec3( dFdx( surf_pos.x ), dFdx( surf_pos.y ), dFdx( surf_pos.z ) );
		vec3 vSigmaY = vec3( dFdy( surf_pos.x ), dFdy( surf_pos.y ), dFdy( surf_pos.z ) );
		vec3 vN = surf_norm;		// normalized

		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );

		float fDet = dot( vSigmaX, R1 );

		fDet *= ( float( gl_FrontFacing ) * 2.0 - 1.0 );

		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );

	}

#endif
`,wc=`
#if NUM_CLIPPING_PLANES > 0

	vec4 plane;

	#pragma unroll_loop
	for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {

		plane = clippingPlanes[ i ];
		if ( dot( vViewPosition, plane.xyz ) > plane.w ) discard;

	}

	#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES

		bool clipped = true;

		#pragma unroll_loop
		for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {

			plane = clippingPlanes[ i ];
			clipped = ( dot( vViewPosition, plane.xyz ) > plane.w ) && clipped;

		}

		if ( clipped ) discard;

	#endif

#endif
`,bc=`
#if NUM_CLIPPING_PLANES > 0

	#if ! defined( PHYSICAL ) && ! defined( PHONG ) && ! defined( MATCAP )
		varying vec3 vViewPosition;
	#endif

	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];

#endif
`,Mc=`
#if NUM_CLIPPING_PLANES > 0 && ! defined( PHYSICAL ) && ! defined( PHONG ) && ! defined( MATCAP )
	varying vec3 vViewPosition;
#endif
`,Ec=`
#if NUM_CLIPPING_PLANES > 0 && ! defined( PHYSICAL ) && ! defined( PHONG ) && ! defined( MATCAP )
	vViewPosition = - mvPosition.xyz;
#endif
`,Tc=`
#ifdef USE_COLOR

	diffuseColor.rgb *= vColor;

#endif
`,Sc=`
#ifdef USE_COLOR

	varying vec3 vColor;

#endif
`,Ac=`
#ifdef USE_COLOR

	varying vec3 vColor;

#endif
`,Lc=`
#ifdef USE_COLOR

	vColor.xyz = color.xyz;

#endif
`,Rc=`
#define PI 3.14159265359
#define PI2 6.28318530718
#define PI_HALF 1.5707963267949
#define RECIPROCAL_PI 0.31830988618
#define RECIPROCAL_PI2 0.15915494
#define LOG2 1.442695
#define EPSILON 1e-6

#define saturate(a) clamp( a, 0.0, 1.0 )
#define whiteCompliment(a) ( 1.0 - saturate( a ) )

float pow2( const in float x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float average( const in vec3 color ) { return dot( color, vec3( 0.3333 ) ); }
// expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
// do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract(sin(sn) * c);
}

struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};

struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};

struct GeometricContext {
	vec3 position;
	vec3 normal;
	vec3 viewDir;
};

vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

}

// http://en.wikibooks.org/wiki/GLSL_Programming/Applying_Matrix_Transformations
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {

	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );

}

vec3 projectOnPlane(in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {

	float distance = dot( planeNormal, point - pointOnPlane );

	return - distance * planeNormal + point;

}

float sideOfPlane( in vec3 point, in vec3 pointOnPlane, in vec3 planeNormal ) {

	return sign( dot( point - pointOnPlane, planeNormal ) );

}

vec3 linePlaneIntersect( in vec3 pointOnLine, in vec3 lineDirection, in vec3 pointOnPlane, in vec3 planeNormal ) {

	return lineDirection * ( dot( planeNormal, pointOnPlane - pointOnLine ) / dot( planeNormal, lineDirection ) ) + pointOnLine;

}

mat3 transposeMat3( const in mat3 m ) {

	mat3 tmp;

	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );

	return tmp;

}

// https://en.wikipedia.org/wiki/Relative_luminance
float linearToRelativeLuminance( const in vec3 color ) {

	vec3 weights = vec3( 0.2126, 0.7152, 0.0722 );

	return dot( weights, color.rgb );

}
`,Pc=`
#ifdef ENVMAP_TYPE_CUBE_UV

#define cubeUV_textureSize (1024.0)

int getFaceFromDirection(vec3 direction) {
	vec3 absDirection = abs(direction);
	int face = -1;
	if( absDirection.x > absDirection.z ) {
		if(absDirection.x > absDirection.y )
			face = direction.x > 0.0 ? 0 : 3;
		else
			face = direction.y > 0.0 ? 1 : 4;
	}
	else {
		if(absDirection.z > absDirection.y )
			face = direction.z > 0.0 ? 2 : 5;
		else
			face = direction.y > 0.0 ? 1 : 4;
	}
	return face;
}
#define cubeUV_maxLods1  (log2(cubeUV_textureSize*0.25) - 1.0)
#define cubeUV_rangeClamp (exp2((6.0 - 1.0) * 2.0))

vec2 MipLevelInfo( vec3 vec, float roughnessLevel, float roughness ) {
	float scale = exp2(cubeUV_maxLods1 - roughnessLevel);
	float dxRoughness = dFdx(roughness);
	float dyRoughness = dFdy(roughness);
	vec3 dx = dFdx( vec * scale * dxRoughness );
	vec3 dy = dFdy( vec * scale * dyRoughness );
	float d = max( dot( dx, dx ), dot( dy, dy ) );
	// Clamp the value to the max mip level counts. hard coded to 6 mips
	d = clamp(d, 1.0, cubeUV_rangeClamp);
	float mipLevel = 0.5 * log2(d);
	return vec2(floor(mipLevel), fract(mipLevel));
}

#define cubeUV_maxLods2 (log2(cubeUV_textureSize*0.25) - 2.0)
#define cubeUV_rcpTextureSize (1.0 / cubeUV_textureSize)

vec2 getCubeUV(vec3 direction, float roughnessLevel, float mipLevel) {
	mipLevel = roughnessLevel > cubeUV_maxLods2 - 3.0 ? 0.0 : mipLevel;
	float a = 16.0 * cubeUV_rcpTextureSize;

	vec2 exp2_packed = exp2( vec2( roughnessLevel, mipLevel ) );
	vec2 rcp_exp2_packed = vec2( 1.0 ) / exp2_packed;
	// float powScale = exp2(roughnessLevel + mipLevel);
	float powScale = exp2_packed.x * exp2_packed.y;
	// float scale =  1.0 / exp2(roughnessLevel + 2.0 + mipLevel);
	float scale = rcp_exp2_packed.x * rcp_exp2_packed.y * 0.25;
	// float mipOffset = 0.75*(1.0 - 1.0/exp2(mipLevel))/exp2(roughnessLevel);
	float mipOffset = 0.75*(1.0 - rcp_exp2_packed.y) * rcp_exp2_packed.x;

	bool bRes = mipLevel == 0.0;
	scale =  bRes && (scale < a) ? a : scale;

	vec3 r;
	vec2 offset;
	int face = getFaceFromDirection(direction);

	float rcpPowScale = 1.0 / powScale;

	if( face == 0) {
		r = vec3(direction.x, -direction.z, direction.y);
		offset = vec2(0.0+mipOffset,0.75 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? a : offset.y;
	}
	else if( face == 1) {
		r = vec3(direction.y, direction.x, direction.z);
		offset = vec2(scale+mipOffset, 0.75 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? a : offset.y;
	}
	else if( face == 2) {
		r = vec3(direction.z, direction.x, direction.y);
		offset = vec2(2.0*scale+mipOffset, 0.75 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? a : offset.y;
	}
	else if( face == 3) {
		r = vec3(direction.x, direction.z, direction.y);
		offset = vec2(0.0+mipOffset,0.5 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? 0.0 : offset.y;
	}
	else if( face == 4) {
		r = vec3(direction.y, direction.x, -direction.z);
		offset = vec2(scale+mipOffset, 0.5 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? 0.0 : offset.y;
	}
	else {
		r = vec3(direction.z, -direction.x, direction.y);
		offset = vec2(2.0*scale+mipOffset, 0.5 * rcpPowScale);
		offset.y = bRes && (offset.y < 2.0*a) ? 0.0 : offset.y;
	}
	r = normalize(r);
	float texelOffset = 0.5 * cubeUV_rcpTextureSize;
	vec2 s = ( r.yz / abs( r.x ) + vec2( 1.0 ) ) * 0.5;
	vec2 base = offset + vec2( texelOffset );
	return base + s * ( scale - 2.0 * texelOffset );
}

#define cubeUV_maxLods3 (log2(cubeUV_textureSize*0.25) - 3.0)

vec4 textureCubeUV( sampler2D envMap, vec3 reflectedDirection, float roughness ) {
	float roughnessVal = roughness* cubeUV_maxLods3;
	float r1 = floor(roughnessVal);
	float r2 = r1 + 1.0;
	float t = fract(roughnessVal);
	vec2 mipInfo = MipLevelInfo(reflectedDirection, r1, roughness);
	float s = mipInfo.y;
	float level0 = mipInfo.x;
	float level1 = level0 + 1.0;
	level1 = level1 > 5.0 ? 5.0 : level1;

	// round to nearest mipmap if we are not interpolating.
	level0 += min( floor( s + 0.5 ), 5.0 );

	// Tri linear interpolation.
	vec2 uv_10 = getCubeUV(reflectedDirection, r1, level0);
	vec4 color10 = envMapTexelToLinear(texture2D(envMap, uv_10));

	vec2 uv_20 = getCubeUV(reflectedDirection, r2, level0);
	vec4 color20 = envMapTexelToLinear(texture2D(envMap, uv_20));

	vec4 result = mix(color10, color20, t);

	return vec4(result.rgb, 1.0);
}

#endif
`,Cc=`
vec3 transformedNormal = normalMatrix * objectNormal;

#ifdef FLIP_SIDED

	transformedNormal = - transformedNormal;

#endif
`,Ic=`
#ifdef USE_DISPLACEMENTMAP

	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;

#endif
`,Dc=`
#ifdef USE_DISPLACEMENTMAP

	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, uv ).x * displacementScale + displacementBias );

#endif
`,Oc=`
#ifdef USE_EMISSIVEMAP

	vec4 emissiveColor = texture2D( emissiveMap, vUv );

	emissiveColor.rgb = emissiveMapTexelToLinear( emissiveColor ).rgb;

	totalEmissiveRadiance *= emissiveColor.rgb;

#endif
`,Fc=`
#ifdef USE_EMISSIVEMAP

	uniform sampler2D emissiveMap;

#endif
`,Uc=`
  gl_FragColor = linearToOutputTexel( gl_FragColor );
`,Bc=`
// For a discussion of what this is, please read this: http://lousodrome.net/blog/light/2013/05/26/gamma-correct-and-hdr-rendering-in-a-32-bits-buffer/

vec4 LinearToLinear( in vec4 value ) {
	return value;
}

vec4 GammaToLinear( in vec4 value, in float gammaFactor ) {
	return vec4( pow( value.rgb, vec3( gammaFactor ) ), value.a );
}

vec4 LinearToGamma( in vec4 value, in float gammaFactor ) {
	return vec4( pow( value.rgb, vec3( 1.0 / gammaFactor ) ), value.a );
}

vec4 sRGBToLinear( in vec4 value ) {
	return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}

vec4 LinearTosRGB( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}

vec4 RGBEToLinear( in vec4 value ) {
	return vec4( value.rgb * exp2( value.a * 255.0 - 128.0 ), 1.0 );
}

vec4 LinearToRGBE( in vec4 value ) {
	float maxComponent = max( max( value.r, value.g ), value.b );
	float fExp = clamp( ceil( log2( maxComponent ) ), -128.0, 127.0 );
	return vec4( value.rgb / exp2( fExp ), ( fExp + 128.0 ) / 255.0 );
//  return vec4( value.brg, ( 3.0 + 128.0 ) / 256.0 );
}

// reference: http://iwasbeingirony.blogspot.ca/2010/06/difference-between-rgbm-and-rgbd.html
vec4 RGBMToLinear( in vec4 value, in float maxRange ) {
	return vec4( value.rgb * value.a * maxRange, 1.0 );
}

vec4 LinearToRGBM( in vec4 value, in float maxRange ) {
	float maxRGB = max( value.r, max( value.g, value.b ) );
	float M = clamp( maxRGB / maxRange, 0.0, 1.0 );
	M = ceil( M * 255.0 ) / 255.0;
	return vec4( value.rgb / ( M * maxRange ), M );
}

// reference: http://iwasbeingirony.blogspot.ca/2010/06/difference-between-rgbm-and-rgbd.html
vec4 RGBDToLinear( in vec4 value, in float maxRange ) {
	return vec4( value.rgb * ( ( maxRange / 255.0 ) / value.a ), 1.0 );
}

vec4 LinearToRGBD( in vec4 value, in float maxRange ) {
	float maxRGB = max( value.r, max( value.g, value.b ) );
	float D = max( maxRange / maxRGB, 1.0 );
	D = min( floor( D ) / 255.0, 1.0 );
	return vec4( value.rgb * ( D * ( 255.0 / maxRange ) ), D );
}

// LogLuv reference: http://graphicrants.blogspot.ca/2009/04/rgbm-color-encoding.html

// M matrix, for encoding
const mat3 cLogLuvM = mat3( 0.2209, 0.3390, 0.4184, 0.1138, 0.6780, 0.7319, 0.0102, 0.1130, 0.2969 );
vec4 LinearToLogLuv( in vec4 value )  {
	vec3 Xp_Y_XYZp = value.rgb * cLogLuvM;
	Xp_Y_XYZp = max( Xp_Y_XYZp, vec3( 1e-6, 1e-6, 1e-6 ) );
	vec4 vResult;
	vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	float Le = 2.0 * log2(Xp_Y_XYZp.y) + 127.0;
	vResult.w = fract( Le );
	vResult.z = ( Le - ( floor( vResult.w * 255.0 ) ) / 255.0 ) / 255.0;
	return vResult;
}

// Inverse M matrix, for decoding
const mat3 cLogLuvInverseM = mat3( 6.0014, -2.7008, -1.7996, -1.3320, 3.1029, -5.7721, 0.3008, -1.0882, 5.6268 );
vec4 LogLuvToLinear( in vec4 value ) {
	float Le = value.z * 255.0 + value.w;
	vec3 Xp_Y_XYZp;
	Xp_Y_XYZp.y = exp2( ( Le - 127.0 ) / 2.0 );
	Xp_Y_XYZp.z = Xp_Y_XYZp.y / value.y;
	Xp_Y_XYZp.x = value.x * Xp_Y_XYZp.z;
	vec3 vRGB = Xp_Y_XYZp.rgb * cLogLuvInverseM;
	return vec4( max( vRGB, 0.0 ), 1.0 );
}
`,Nc=`
#ifdef USE_ENVMAP

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG )

		vec3 cameraToVertex = normalize( vWorldPosition - cameraPosition );

		// Transforming Normal Vectors with the Inverse Transformation
		vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );

		#ifdef ENVMAP_MODE_REFLECTION

			vec3 reflectVec = reflect( cameraToVertex, worldNormal );

		#else

			vec3 reflectVec = refract( cameraToVertex, worldNormal, refractionRatio );

		#endif

	#else

		vec3 reflectVec = vReflect;

	#endif

	#ifdef ENVMAP_TYPE_CUBE

		vec4 envColor = textureCube( envMap, vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );

	#elif defined( ENVMAP_TYPE_EQUIREC )

		vec2 sampleUV;

		reflectVec = normalize( reflectVec );

		sampleUV.y = asin( clamp( reflectVec.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;

		sampleUV.x = atan( reflectVec.z, reflectVec.x ) * RECIPROCAL_PI2 + 0.5;

		vec4 envColor = texture2D( envMap, sampleUV );

	#elif defined( ENVMAP_TYPE_SPHERE )

		reflectVec = normalize( reflectVec );

		vec3 reflectView = normalize( ( viewMatrix * vec4( reflectVec, 0.0 ) ).xyz + vec3( 0.0, 0.0, 1.0 ) );

		vec4 envColor = texture2D( envMap, reflectView.xy * 0.5 + 0.5 );

	#else

		vec4 envColor = vec4( 0.0 );

	#endif

	envColor = envMapTexelToLinear( envColor );

	#ifdef ENVMAP_BLENDING_MULTIPLY

		outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );

	#elif defined( ENVMAP_BLENDING_MIX )

		outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );

	#elif defined( ENVMAP_BLENDING_ADD )

		outgoingLight += envColor.xyz * specularStrength * reflectivity;

	#endif

#endif
`,Gc=`
#if defined( USE_ENVMAP ) || defined( PHYSICAL )
	uniform float reflectivity;
	uniform float envMapIntensity;
#endif

#ifdef USE_ENVMAP

	#if ! defined( PHYSICAL ) && ( defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) )
		varying vec3 vWorldPosition;
	#endif

	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	uniform float flipEnvMap;
	uniform int maxMipLevel;

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( PHYSICAL )
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif

#endif
`,zc=`
#ifdef USE_ENVMAP

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG )
		varying vec3 vWorldPosition;

	#else

		varying vec3 vReflect;
		uniform float refractionRatio;

	#endif

#endif
`,Hc=`
#ifdef USE_ENVMAP

	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG )

		vWorldPosition = worldPosition.xyz;

	#else

		vec3 cameraToVertex = normalize( worldPosition.xyz - cameraPosition );

		vec3 worldNormal = inverseTransformDirection( transformedNormal, viewMatrix );

		#ifdef ENVMAP_MODE_REFLECTION

			vReflect = reflect( cameraToVertex, worldNormal );

		#else

			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );

		#endif

	#endif

#endif
`,Vc=`
#ifdef USE_FOG

	fogDepth = -mvPosition.z;

#endif
`,kc=`
#ifdef USE_FOG

	varying float fogDepth;

#endif
`,Wc=`
#ifdef USE_FOG

	#ifdef FOG_EXP2

		float fogFactor = whiteCompliment( exp2( - fogDensity * fogDensity * fogDepth * fogDepth * LOG2 ) );

	#else

		float fogFactor = smoothstep( fogNear, fogFar, fogDepth );

	#endif

	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );

#endif
`,Xc=`
#ifdef USE_FOG

	uniform vec3 fogColor;
	varying float fogDepth;

	#ifdef FOG_EXP2

		uniform float fogDensity;

	#else

		uniform float fogNear;
		uniform float fogFar;

	#endif

#endif
`,jc=`
#ifdef TOON

	uniform sampler2D gradientMap;

	vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {

		// dotNL will be from -1.0 to 1.0
		float dotNL = dot( normal, lightDirection );
		vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );

		#ifdef USE_GRADIENTMAP

			return texture2D( gradientMap, coord ).rgb;

		#else

			return ( coord.x < 0.7 ) ? vec3( 0.7 ) : vec3( 1.0 );

		#endif


	}

#endif
`,qc=`
#ifdef USE_LIGHTMAP

	reflectedLight.indirectDiffuse += PI * texture2D( lightMap, vUv2 ).xyz * lightMapIntensity; // factor of PI should not be present; included here to prevent breakage

#endif
`,Yc=`
#ifdef USE_LIGHTMAP

	uniform sampler2D lightMap;
	uniform float lightMapIntensity;

#endif
`,Zc=`
vec3 diffuse = vec3( 1.0 );

GeometricContext geometry;
geometry.position = mvPosition.xyz;
geometry.normal = normalize( transformedNormal );
geometry.viewDir = normalize( -mvPosition.xyz );

GeometricContext backGeometry;
backGeometry.position = geometry.position;
backGeometry.normal = -geometry.normal;
backGeometry.viewDir = geometry.viewDir;

vLightFront = vec3( 0.0 );

#ifdef DOUBLE_SIDED
	vLightBack = vec3( 0.0 );
#endif

IncidentLight directLight;
float dotNL;
vec3 directLightColor_Diffuse;

#if NUM_POINT_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {

		getPointDirectLightIrradiance( pointLights[ i ], geometry, directLight );

		dotNL = dot( geometry.normal, directLight.direction );
		directLightColor_Diffuse = PI * directLight.color;

		vLightFront += saturate( dotNL ) * directLightColor_Diffuse;

		#ifdef DOUBLE_SIDED

			vLightBack += saturate( -dotNL ) * directLightColor_Diffuse;

		#endif

	}

#endif

#if NUM_SPOT_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {

		getSpotDirectLightIrradiance( spotLights[ i ], geometry, directLight );

		dotNL = dot( geometry.normal, directLight.direction );
		directLightColor_Diffuse = PI * directLight.color;

		vLightFront += saturate( dotNL ) * directLightColor_Diffuse;

		#ifdef DOUBLE_SIDED

			vLightBack += saturate( -dotNL ) * directLightColor_Diffuse;

		#endif
	}

#endif

/*
#if NUM_RECT_AREA_LIGHTS > 0

	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {

		// TODO (abelnation): implement

	}

#endif
*/

#if NUM_DIR_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

		getDirectionalDirectLightIrradiance( directionalLights[ i ], geometry, directLight );

		dotNL = dot( geometry.normal, directLight.direction );
		directLightColor_Diffuse = PI * directLight.color;

		vLightFront += saturate( dotNL ) * directLightColor_Diffuse;

		#ifdef DOUBLE_SIDED

			vLightBack += saturate( -dotNL ) * directLightColor_Diffuse;

		#endif

	}

#endif

#if NUM_HEMI_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {

		vLightFront += getHemisphereLightIrradiance( hemisphereLights[ i ], geometry );

		#ifdef DOUBLE_SIDED

			vLightBack += getHemisphereLightIrradiance( hemisphereLights[ i ], backGeometry );

		#endif

	}

#endif
`,Jc=`
uniform vec3 ambientLightColor;

vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {

	vec3 irradiance = ambientLightColor;

	#ifndef PHYSICALLY_CORRECT_LIGHTS

		irradiance *= PI;

	#endif

	return irradiance;

}

#if NUM_DIR_LIGHTS > 0

	struct DirectionalLight {
		vec3 direction;
		vec3 color;

		int shadow;
		float shadowBias;
		float shadowRadius;
		vec2 shadowMapSize;
	};

	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];

	void getDirectionalDirectLightIrradiance( const in DirectionalLight directionalLight, const in GeometricContext geometry, out IncidentLight directLight ) {

		directLight.color = directionalLight.color;
		directLight.direction = directionalLight.direction;
		directLight.visible = true;

	}

#endif


#if NUM_POINT_LIGHTS > 0

	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;

		int shadow;
		float shadowBias;
		float shadowRadius;
		vec2 shadowMapSize;
		float shadowCameraNear;
		float shadowCameraFar;
	};

	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];

	// directLight is an out parameter as having it as a return value caused compiler errors on some devices
	void getPointDirectLightIrradiance( const in PointLight pointLight, const in GeometricContext geometry, out IncidentLight directLight ) {

		vec3 lVector = pointLight.position - geometry.position;
		directLight.direction = normalize( lVector );

		float lightDistance = length( lVector );

		directLight.color = pointLight.color;
		directLight.color *= punctualLightIntensityToIrradianceFactor( lightDistance, pointLight.distance, pointLight.decay );
		directLight.visible = ( directLight.color != vec3( 0.0 ) );

	}

#endif


#if NUM_SPOT_LIGHTS > 0

	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;

		int shadow;
		float shadowBias;
		float shadowRadius;
		vec2 shadowMapSize;
	};

	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];

	// directLight is an out parameter as having it as a return value caused compiler errors on some devices
	void getSpotDirectLightIrradiance( const in SpotLight spotLight, const in GeometricContext geometry, out IncidentLight directLight  ) {

		vec3 lVector = spotLight.position - geometry.position;
		directLight.direction = normalize( lVector );

		float lightDistance = length( lVector );
		float angleCos = dot( directLight.direction, spotLight.direction );

		if ( angleCos > spotLight.coneCos ) {

			float spotEffect = smoothstep( spotLight.coneCos, spotLight.penumbraCos, angleCos );

			directLight.color = spotLight.color;
			directLight.color *= spotEffect * punctualLightIntensityToIrradianceFactor( lightDistance, spotLight.distance, spotLight.decay );
			directLight.visible = true;

		} else {

			directLight.color = vec3( 0.0 );
			directLight.visible = false;

		}
	}

#endif


#if NUM_RECT_AREA_LIGHTS > 0

	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};

	// Pre-computed values of LinearTransformedCosine approximation of BRDF
	// BRDF approximation Texture is 64x64
	uniform sampler2D ltc_1; // RGBA Float
	uniform sampler2D ltc_2; // RGBA Float

	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];

#endif


#if NUM_HEMI_LIGHTS > 0

	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};

	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];

	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in GeometricContext geometry ) {

		float dotNL = dot( geometry.normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;

		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );

		#ifndef PHYSICALLY_CORRECT_LIGHTS

			irradiance *= PI;

		#endif

		return irradiance;

	}

#endif
`,Qc=`
#if defined( USE_ENVMAP ) && defined( PHYSICAL )

	vec3 getLightProbeIndirectIrradiance( /*const in SpecularLightProbe specularLightProbe,*/ const in GeometricContext geometry, const in int maxMIPLevel ) {

		vec3 worldNormal = inverseTransformDirection( geometry.normal, viewMatrix );

		#ifdef ENVMAP_TYPE_CUBE

			vec3 queryVec = vec3( flipEnvMap * worldNormal.x, worldNormal.yz );

			// TODO: replace with properly filtered cubemaps and access the irradiance LOD level, be it the last LOD level
			// of a specular cubemap, or just the default level of a specially created irradiance cubemap.

			#ifdef TEXTURE_LOD_EXT

				vec4 envMapColor = textureCubeLodEXT( envMap, queryVec, float( maxMIPLevel ) );

			#else

				// force the bias high to get the last LOD level as it is the most blurred.
				vec4 envMapColor = textureCube( envMap, queryVec, float( maxMIPLevel ) );

			#endif

			envMapColor.rgb = envMapTexelToLinear( envMapColor ).rgb;

		#elif defined( ENVMAP_TYPE_CUBE_UV )

			vec3 queryVec = vec3( flipEnvMap * worldNormal.x, worldNormal.yz );
			vec4 envMapColor = textureCubeUV( envMap, queryVec, 1.0 );

		#else

			vec4 envMapColor = vec4( 0.0 );

		#endif

		return PI * envMapColor.rgb * envMapIntensity;

	}

	// taken from here: http://casual-effects.blogspot.ca/2011/08/plausible-environment-lighting-in-two.html
	float getSpecularMIPLevel( const in float blinnShininessExponent, const in int maxMIPLevel ) {

		//float envMapWidth = pow( 2.0, maxMIPLevelScalar );
		//float desiredMIPLevel = log2( envMapWidth * sqrt( 3.0 ) ) - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );

		float maxMIPLevelScalar = float( maxMIPLevel );
		float desiredMIPLevel = maxMIPLevelScalar + 0.79248 - 0.5 * log2( pow2( blinnShininessExponent ) + 1.0 );

		// clamp to allowable LOD ranges.
		return clamp( desiredMIPLevel, 0.0, maxMIPLevelScalar );

	}

	vec3 getLightProbeIndirectRadiance( /*const in SpecularLightProbe specularLightProbe,*/ const in GeometricContext geometry, const in float blinnShininessExponent, const in int maxMIPLevel ) {

		#ifdef ENVMAP_MODE_REFLECTION

			vec3 reflectVec = reflect( -geometry.viewDir, geometry.normal );

		#else

			vec3 reflectVec = refract( -geometry.viewDir, geometry.normal, refractionRatio );

		#endif

		reflectVec = inverseTransformDirection( reflectVec, viewMatrix );

		float specularMIPLevel = getSpecularMIPLevel( blinnShininessExponent, maxMIPLevel );

		#ifdef ENVMAP_TYPE_CUBE

			vec3 queryReflectVec = vec3( flipEnvMap * reflectVec.x, reflectVec.yz );

			#ifdef TEXTURE_LOD_EXT

				vec4 envMapColor = textureCubeLodEXT( envMap, queryReflectVec, specularMIPLevel );

			#else

				vec4 envMapColor = textureCube( envMap, queryReflectVec, specularMIPLevel );

			#endif

			envMapColor.rgb = envMapTexelToLinear( envMapColor ).rgb;

		#elif defined( ENVMAP_TYPE_CUBE_UV )

			vec3 queryReflectVec = vec3( flipEnvMap * reflectVec.x, reflectVec.yz );
			vec4 envMapColor = textureCubeUV( envMap, queryReflectVec, BlinnExponentToGGXRoughness(blinnShininessExponent ));

		#elif defined( ENVMAP_TYPE_EQUIREC )

			vec2 sampleUV;
			sampleUV.y = asin( clamp( reflectVec.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
			sampleUV.x = atan( reflectVec.z, reflectVec.x ) * RECIPROCAL_PI2 + 0.5;

			#ifdef TEXTURE_LOD_EXT

				vec4 envMapColor = texture2DLodEXT( envMap, sampleUV, specularMIPLevel );

			#else

				vec4 envMapColor = texture2D( envMap, sampleUV, specularMIPLevel );

			#endif

			envMapColor.rgb = envMapTexelToLinear( envMapColor ).rgb;

		#elif defined( ENVMAP_TYPE_SPHERE )

			vec3 reflectView = normalize( ( viewMatrix * vec4( reflectVec, 0.0 ) ).xyz + vec3( 0.0,0.0,1.0 ) );

			#ifdef TEXTURE_LOD_EXT

				vec4 envMapColor = texture2DLodEXT( envMap, reflectView.xy * 0.5 + 0.5, specularMIPLevel );

			#else

				vec4 envMapColor = texture2D( envMap, reflectView.xy * 0.5 + 0.5, specularMIPLevel );

			#endif

			envMapColor.rgb = envMapTexelToLinear( envMapColor ).rgb;

		#endif

		return envMapColor.rgb * envMapIntensity;

	}

#endif
`,Kc=`
BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;
`,$c=`
varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif


struct BlinnPhongMaterial {

	vec3	diffuseColor;
	vec3	specularColor;
	float	specularShininess;
	float	specularStrength;

};

void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in GeometricContext geometry, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {

	#ifdef TOON

		vec3 irradiance = getGradientIrradiance( geometry.normal, directLight.direction ) * directLight.color;

	#else

		float dotNL = saturate( dot( geometry.normal, directLight.direction ) );
		vec3 irradiance = dotNL * directLight.color;

	#endif

	#ifndef PHYSICALLY_CORRECT_LIGHTS

		irradiance *= PI; // punctual light

	#endif

	reflectedLight.directDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );

	reflectedLight.directSpecular += irradiance * BRDF_Specular_BlinnPhong( directLight, geometry, material.specularColor, material.specularShininess ) * material.specularStrength;

}

void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in GeometricContext geometry, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {

	reflectedLight.indirectDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );

}

#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong

#define Material_LightProbeLOD( material )	(0)
`,eu=`
PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
material.specularRoughness = clamp( roughnessFactor, 0.04, 1.0 );
#ifdef STANDARD
	material.specularColor = mix( vec3( DEFAULT_SPECULAR_COEFFICIENT ), diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = mix( vec3( MAXIMUM_SPECULAR_COEFFICIENT * pow2( reflectivity ) ), diffuseColor.rgb, metalnessFactor );
	material.clearCoat = saturate( clearCoat ); // Burley clearcoat model
	material.clearCoatRoughness = clamp( clearCoatRoughness, 0.04, 1.0 );
#endif
`,tu=`
struct PhysicalMaterial {

	vec3	diffuseColor;
	float	specularRoughness;
	vec3	specularColor;

	#ifndef STANDARD
		float clearCoat;
		float clearCoatRoughness;
	#endif

};

#define MAXIMUM_SPECULAR_COEFFICIENT 0.16
#define DEFAULT_SPECULAR_COEFFICIENT 0.04

// Clear coat directional hemishperical reflectance (this approximation should be improved)
float clearCoatDHRApprox( const in float roughness, const in float dotNL ) {

	return DEFAULT_SPECULAR_COEFFICIENT + ( 1.0 - DEFAULT_SPECULAR_COEFFICIENT ) * ( pow( 1.0 - dotNL, 5.0 ) * pow( 1.0 - roughness, 2.0 ) );

}

#if NUM_RECT_AREA_LIGHTS > 0

	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

		vec3 normal = geometry.normal;
		vec3 viewDir = geometry.viewDir;
		vec3 position = geometry.position;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.specularRoughness;

		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight; // counterclockwise; light shines in local neg z direction
		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;

		vec2 uv = LTC_Uv( normal, viewDir, roughness );

		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );

		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);

		// LTC Fresnel Approximation by Stephen Hill
		// http://blog.selfshadow.com/publications/s2016-advances/s2016_ltc_fresnel.pdf
		vec3 fresnel = ( material.specularColor * t2.x + ( vec3( 1.0 ) - material.specularColor ) * t2.y );

		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );

		reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );

	}

#endif

void RE_Direct_Physical( const in IncidentLight directLight, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

	float dotNL = saturate( dot( geometry.normal, directLight.direction ) );

	vec3 irradiance = dotNL * directLight.color;

	#ifndef PHYSICALLY_CORRECT_LIGHTS

		irradiance *= PI; // punctual light

	#endif

	#ifndef STANDARD
		float clearCoatDHR = material.clearCoat * clearCoatDHRApprox( material.clearCoatRoughness, dotNL );
	#else
		float clearCoatDHR = 0.0;
	#endif

	reflectedLight.directSpecular += ( 1.0 - clearCoatDHR ) * irradiance * BRDF_Specular_GGX( directLight, geometry, material.specularColor, material.specularRoughness );

	reflectedLight.directDiffuse += ( 1.0 - clearCoatDHR ) * irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );

	#ifndef STANDARD

		reflectedLight.directSpecular += irradiance * material.clearCoat * BRDF_Specular_GGX( directLight, geometry, vec3( DEFAULT_SPECULAR_COEFFICIENT ), material.clearCoatRoughness );

	#endif

}

void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

	reflectedLight.indirectDiffuse += irradiance * BRDF_Diffuse_Lambert( material.diffuseColor );

}

void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 clearCoatRadiance, const in GeometricContext geometry, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {

	#ifndef STANDARD
		float dotNV = saturate( dot( geometry.normal, geometry.viewDir ) );
		float dotNL = dotNV;
		float clearCoatDHR = material.clearCoat * clearCoatDHRApprox( material.clearCoatRoughness, dotNL );
	#else
		float clearCoatDHR = 0.0;
	#endif

	reflectedLight.indirectSpecular += ( 1.0 - clearCoatDHR ) * radiance * BRDF_Specular_GGX_Environment( geometry, material.specularColor, material.specularRoughness );

	#ifndef STANDARD

		reflectedLight.indirectSpecular += clearCoatRadiance * material.clearCoat * BRDF_Specular_GGX_Environment( geometry, vec3( DEFAULT_SPECULAR_COEFFICIENT ), material.clearCoatRoughness );

	#endif

}

#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical

#define Material_BlinnShininessExponent( material )   GGXRoughnessToBlinnExponent( material.specularRoughness )
#define Material_ClearCoat_BlinnShininessExponent( material )   GGXRoughnessToBlinnExponent( material.clearCoatRoughness )

// ref: https://seblagarde.files.wordpress.com/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {

	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );

}
`,ru=`
/**
 * This is a template that can be used to light a material, it uses pluggable
 * RenderEquations (RE)for specific lighting scenarios.
 *
 * Instructions for use:
 * - Ensure that both RE_Direct, RE_IndirectDiffuse and RE_IndirectSpecular are defined
 * - If you have defined an RE_IndirectSpecular, you need to also provide a Material_LightProbeLOD. <---- ???
 * - Create a material parameter that is to be passed as the third parameter to your lighting functions.
 *
 * TODO:
 * - Add area light support.
 * - Add sphere light support.
 * - Add diffuse light probe (irradiance cubemap) support.
 */

GeometricContext geometry;

geometry.position = - vViewPosition;
geometry.normal = normal;
geometry.viewDir = normalize( vViewPosition );

IncidentLight directLight;

#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )

	PointLight pointLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {

		pointLight = pointLights[ i ];

		getPointDirectLightIrradiance( pointLight, geometry, directLight );

		#ifdef USE_SHADOWMAP
		directLight.color *= all( bvec2( pointLight.shadow, directLight.visible ) ) ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
		#endif

		RE_Direct( directLight, geometry, material, reflectedLight );

	}

#endif

#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )

	SpotLight spotLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {

		spotLight = spotLights[ i ];

		getSpotDirectLightIrradiance( spotLight, geometry, directLight );

		#ifdef USE_SHADOWMAP
		directLight.color *= all( bvec2( spotLight.shadow, directLight.visible ) ) ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowBias, spotLight.shadowRadius, vSpotShadowCoord[ i ] ) : 1.0;
		#endif

		RE_Direct( directLight, geometry, material, reflectedLight );

	}

#endif

#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )

	DirectionalLight directionalLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

		directionalLight = directionalLights[ i ];

		getDirectionalDirectLightIrradiance( directionalLight, geometry, directLight );

		#ifdef USE_SHADOWMAP
		directLight.color *= all( bvec2( directionalLight.shadow, directLight.visible ) ) ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif

		RE_Direct( directLight, geometry, material, reflectedLight );

	}

#endif

#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )

	RectAreaLight rectAreaLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {

		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometry, material, reflectedLight );

	}

#endif

#if defined( RE_IndirectDiffuse )

	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );

	#if ( NUM_HEMI_LIGHTS > 0 )

		#pragma unroll_loop
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {

			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometry );

		}

	#endif

#endif

#if defined( RE_IndirectSpecular )

	vec3 radiance = vec3( 0.0 );
	vec3 clearCoatRadiance = vec3( 0.0 );

#endif
`,iu=`
#if defined( RE_IndirectDiffuse )

	#ifdef USE_LIGHTMAP

		vec3 lightMapIrradiance = texture2D( lightMap, vUv2 ).xyz * lightMapIntensity;

		#ifndef PHYSICALLY_CORRECT_LIGHTS

			lightMapIrradiance *= PI; // factor of PI should not be present; included here to prevent breakage

		#endif

		irradiance += lightMapIrradiance;

	#endif

	#if defined( USE_ENVMAP ) && defined( PHYSICAL ) && defined( ENVMAP_TYPE_CUBE_UV )

		irradiance += getLightProbeIndirectIrradiance( /*lightProbe,*/ geometry, maxMipLevel );

	#endif

#endif

#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )

	radiance += getLightProbeIndirectRadiance( /*specularLightProbe,*/ geometry, Material_BlinnShininessExponent( material ), maxMipLevel );

	#ifndef STANDARD
		clearCoatRadiance += getLightProbeIndirectRadiance( /*specularLightProbe,*/ geometry, Material_ClearCoat_BlinnShininessExponent( material ), maxMipLevel );
	#endif

#endif
`,nu=`
#if defined( RE_IndirectDiffuse )

	RE_IndirectDiffuse( irradiance, geometry, material, reflectedLight );

#endif

#if defined( RE_IndirectSpecular )

	RE_IndirectSpecular( radiance, clearCoatRadiance, geometry, material, reflectedLight );

#endif
`,au=`
#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )

	gl_FragDepthEXT = log2( vFragDepth ) * logDepthBufFC * 0.5;

#endif
`,su=`
#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )

	uniform float logDepthBufFC;
	varying float vFragDepth;

#endif
`,ou=`
#ifdef USE_LOGDEPTHBUF

	#ifdef USE_LOGDEPTHBUF_EXT

		varying float vFragDepth;

	#else

		uniform float logDepthBufFC;

	#endif

#endif
`,hu=`
#ifdef USE_LOGDEPTHBUF

	#ifdef USE_LOGDEPTHBUF_EXT

		vFragDepth = 1.0 + gl_Position.w;

	#else

		gl_Position.z = log2( max( EPSILON, gl_Position.w + 1.0 ) ) * logDepthBufFC - 1.0;

		gl_Position.z *= gl_Position.w;

	#endif

#endif
`,cu=`
#ifdef USE_MAP

	vec4 texelColor = texture2D( map, vUv );

	texelColor = mapTexelToLinear( texelColor );
	diffuseColor *= texelColor;

#endif
`,uu=`
#ifdef USE_MAP

	uniform sampler2D map;

#endif
`,lu=`
#ifdef USE_MAP

	vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	vec4 mapTexel = texture2D( map, uv );
	diffuseColor *= mapTexelToLinear( mapTexel );

#endif
`,fu=`
#ifdef USE_MAP

	uniform mat3 uvTransform;
	uniform sampler2D map;

#endif
`,du=`
float metalnessFactor = metalness;

#ifdef USE_METALNESSMAP

	vec4 texelMetalness = texture2D( metalnessMap, vUv );

	// reads channel B, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	metalnessFactor *= texelMetalness.b;

#endif
`,pu=`
#ifdef USE_METALNESSMAP

	uniform sampler2D metalnessMap;

#endif
`,mu=`
#ifdef USE_MORPHNORMALS

	objectNormal += ( morphNormal0 - normal ) * morphTargetInfluences[ 0 ];
	objectNormal += ( morphNormal1 - normal ) * morphTargetInfluences[ 1 ];
	objectNormal += ( morphNormal2 - normal ) * morphTargetInfluences[ 2 ];
	objectNormal += ( morphNormal3 - normal ) * morphTargetInfluences[ 3 ];

#endif
`,vu=`
#ifdef USE_MORPHTARGETS

	#ifndef USE_MORPHNORMALS

	uniform float morphTargetInfluences[ 8 ];

	#else

	uniform float morphTargetInfluences[ 4 ];

	#endif

#endif
`,gu=`
#ifdef USE_MORPHTARGETS

	transformed += ( morphTarget0 - position ) * morphTargetInfluences[ 0 ];
	transformed += ( morphTarget1 - position ) * morphTargetInfluences[ 1 ];
	transformed += ( morphTarget2 - position ) * morphTargetInfluences[ 2 ];
	transformed += ( morphTarget3 - position ) * morphTargetInfluences[ 3 ];

	#ifndef USE_MORPHNORMALS

	transformed += ( morphTarget4 - position ) * morphTargetInfluences[ 4 ];
	transformed += ( morphTarget5 - position ) * morphTargetInfluences[ 5 ];
	transformed += ( morphTarget6 - position ) * morphTargetInfluences[ 6 ];
	transformed += ( morphTarget7 - position ) * morphTargetInfluences[ 7 ];

	#endif

#endif
`,yu=`
#ifdef FLAT_SHADED

	// Workaround for Adreno/Nexus5 not able able to do dFdx( vViewPosition ) ...

	vec3 fdx = vec3( dFdx( vViewPosition.x ), dFdx( vViewPosition.y ), dFdx( vViewPosition.z ) );
	vec3 fdy = vec3( dFdy( vViewPosition.x ), dFdy( vViewPosition.y ), dFdy( vViewPosition.z ) );
	vec3 normal = normalize( cross( fdx, fdy ) );

#else

	vec3 normal = normalize( vNormal );

	#ifdef DOUBLE_SIDED

		normal = normal * ( float( gl_FrontFacing ) * 2.0 - 1.0 );

	#endif

#endif
`,xu=`
#ifdef USE_NORMALMAP

	#ifdef OBJECTSPACE_NORMALMAP

		normal = texture2D( normalMap, vUv ).xyz * 2.0 - 1.0; // overrides both flatShading and attribute normals

		#ifdef FLIP_SIDED

			normal = - normal;

		#endif

		#ifdef DOUBLE_SIDED

			normal = normal * ( float( gl_FrontFacing ) * 2.0 - 1.0 );

		#endif

		normal = normalize( normalMatrix * normal );

	#else // tangent-space normal map

		normal = perturbNormal2Arb( -vViewPosition, normal );

	#endif

#elif defined( USE_BUMPMAP )

	normal = perturbNormalArb( -vViewPosition, normal, dHdxy_fwd() );

#endif
`,_u=`
#ifdef USE_NORMALMAP

	uniform sampler2D normalMap;
	uniform vec2 normalScale;

	#ifdef OBJECTSPACE_NORMALMAP

		uniform mat3 normalMatrix;

	#else

		// Per-Pixel Tangent Space Normal Mapping
		// http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html

		vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm ) {

			// Workaround for Adreno 3XX dFd*( vec3 ) bug. See #9988

			vec3 q0 = vec3( dFdx( eye_pos.x ), dFdx( eye_pos.y ), dFdx( eye_pos.z ) );
			vec3 q1 = vec3( dFdy( eye_pos.x ), dFdy( eye_pos.y ), dFdy( eye_pos.z ) );
			vec2 st0 = dFdx( vUv.st );
			vec2 st1 = dFdy( vUv.st );

			float scale = sign( st1.t * st0.s - st0.t * st1.s ); // we do not care about the magnitude

			vec3 S = normalize( ( q0 * st1.t - q1 * st0.t ) * scale );
			vec3 T = normalize( ( - q0 * st1.s + q1 * st0.s ) * scale );
			vec3 N = normalize( surf_norm );
			mat3 tsn = mat3( S, T, N );

			vec3 mapN = texture2D( normalMap, vUv ).xyz * 2.0 - 1.0;

			mapN.xy *= normalScale;
			mapN.xy *= ( float( gl_FrontFacing ) * 2.0 - 1.0 );

			return normalize( tsn * mapN );

		}

	#endif

#endif
`,wu=`
vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}

vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}

const float PackUpscale = 256. / 255.; // fraction -> 0..1 (including 1)
const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)

const vec3 PackFactors = vec3( 256. * 256. * 256., 256. * 256.,  256. );
const vec4 UnpackFactors = UnpackDownscale / vec4( PackFactors, 1. );

const float ShiftRight8 = 1. / 256.;

vec4 packDepthToRGBA( const in float v ) {
	vec4 r = vec4( fract( v * PackFactors ), v );
	r.yzw -= r.xyz * ShiftRight8; // tidy overflow
	return r * PackUpscale;
}

float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors );
}

// NOTE: viewZ/eyeZ is < 0 when in front of the camera per OpenGL conventions

float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float linearClipZ, const in float near, const in float far ) {
	return linearClipZ * ( near - far ) - near;
}

float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return (( near + viewZ ) * far ) / (( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float invClipZ, const in float near, const in float far ) {
	return ( near * far ) / ( ( far - near ) * invClipZ - far );
}
`,bu=`
#ifdef PREMULTIPLIED_ALPHA

	// Get get normal blending with premultipled, use with CustomBlending, OneFactor, OneMinusSrcAlphaFactor, AddEquation.
	gl_FragColor.rgb *= gl_FragColor.a;

#endif
`,Mu=`
vec4 mvPosition = modelViewMatrix * vec4( transformed, 1.0 );

gl_Position = projectionMatrix * mvPosition;
`,Eu=`
#if defined( DITHERING )

  gl_FragColor.rgb = dithering( gl_FragColor.rgb );

#endif
`,Tu=`
#if defined( DITHERING )

	// based on https://www.shadertoy.com/view/MslGR8
	vec3 dithering( vec3 color ) {
		//Calculate grid position
		float grid_position = rand( gl_FragCoord.xy );

		//Shift the individual colors differently, thus making it even harder to see the dithering pattern
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );

		//modify shift acording to grid position.
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );

		//shift the color by dither_shift
		return color + dither_shift_RGB;
	}

#endif
`,Su=`
float roughnessFactor = roughness;

#ifdef USE_ROUGHNESSMAP

	vec4 texelRoughness = texture2D( roughnessMap, vUv );

	// reads channel G, compatible with a combined OcclusionRoughnessMetallic (RGB) texture
	roughnessFactor *= texelRoughness.g;

#endif
`,Au=`
#ifdef USE_ROUGHNESSMAP

	uniform sampler2D roughnessMap;

#endif
`,Lu=`
#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHTS ];

	#endif

	#if NUM_SPOT_LIGHTS > 0

		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHTS ];
		varying vec4 vSpotShadowCoord[ NUM_SPOT_LIGHTS ];

	#endif

	#if NUM_POINT_LIGHTS > 0

		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHTS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHTS ];

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): create uniforms for area light shadows

	#endif
	*/

	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {

		return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );

	}

	float texture2DShadowLerp( sampler2D depths, vec2 size, vec2 uv, float compare ) {

		const vec2 offset = vec2( 0.0, 1.0 );

		vec2 texelSize = vec2( 1.0 ) / size;
		vec2 centroidUV = floor( uv * size + 0.5 ) / size;

		float lb = texture2DCompare( depths, centroidUV + texelSize * offset.xx, compare );
		float lt = texture2DCompare( depths, centroidUV + texelSize * offset.xy, compare );
		float rb = texture2DCompare( depths, centroidUV + texelSize * offset.yx, compare );
		float rt = texture2DCompare( depths, centroidUV + texelSize * offset.yy, compare );

		vec2 f = fract( uv * size + 0.5 );

		float a = mix( lb, lt, f.y );
		float b = mix( rb, rt, f.y );
		float c = mix( a, b, f.x );

		return c;

	}

	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

		float shadow = 1.0;

		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;

		// if ( something && something ) breaks ATI OpenGL shader compiler
		// if ( all( something, something ) ) using this instead

		bvec4 inFrustumVec = bvec4 ( shadowCoord.x >= 0.0, shadowCoord.x <= 1.0, shadowCoord.y >= 0.0, shadowCoord.y <= 1.0 );
		bool inFrustum = all( inFrustumVec );

		bvec2 frustumTestVec = bvec2( inFrustum, shadowCoord.z <= 1.0 );

		bool frustumTest = all( frustumTestVec );

		if ( frustumTest ) {

		#if defined( SHADOWMAP_TYPE_PCF )

			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;

			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;

			shadow = (
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 9.0 );

		#elif defined( SHADOWMAP_TYPE_PCF_SOFT )

			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;

			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;

			shadow = (
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy, shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DShadowLerp( shadowMap, shadowMapSize, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 9.0 );

		#else // no percentage-closer filtering:

			shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );

		#endif

		}

		return shadow;

	}

	// cubeToUV() maps a 3D direction vector suitable for cube texture mapping to a 2D
	// vector suitable for 2D texture mapping. This code uses the following layout for the
	// 2D texture:
	//
	// xzXZ
	//  y Y
	//
	// Y - Positive y direction
	// y - Negative y direction
	// X - Positive x direction
	// x - Negative x direction
	// Z - Positive z direction
	// z - Negative z direction
	//
	// Source and test bed:
	// https://gist.github.com/tschw/da10c43c467ce8afd0c4

	vec2 cubeToUV( vec3 v, float texelSizeY ) {

		// Number of texels to avoid at the edge of each square

		vec3 absV = abs( v );

		// Intersect unit cube

		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;

		// Apply scale to avoid seams

		// two texels less per square (one texel will do for NEAREST)
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );

		// Unwrap

		// space: -1 ... 1 range for each square
		//
		// #X##		dim    := ( 4 , 2 )
		//  # #		center := ( 1 , 1 )

		vec2 planar = v.xy;

		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;

		if ( absV.z >= almostOne ) {

			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;

		} else if ( absV.x >= almostOne ) {

			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;

		} else if ( absV.y >= almostOne ) {

			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;

		}

		// Transform to UV space

		// scale := 0.5 / dim
		// translate := ( center + 0.5 ) / dim
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );

	}

	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {

		vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );

		// for point lights, the uniform @vShadowCoord is re-purposed to hold
		// the vector from the light to the world-space position of the fragment.
		vec3 lightToPosition = shadowCoord.xyz;

		// dp = normalized distance from light to fragment position
		float dp = ( length( lightToPosition ) - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear ); // need to clamp?
		dp += shadowBias;

		// bd3D = base direction 3D
		vec3 bd3D = normalize( lightToPosition );

		#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT )

			vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;

			return (
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
			) * ( 1.0 / 9.0 );

		#else // no percentage-closer filtering

			return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );

		#endif

	}

#endif
`,Ru=`
#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHTS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHTS ];

	#endif

	#if NUM_SPOT_LIGHTS > 0

		uniform mat4 spotShadowMatrix[ NUM_SPOT_LIGHTS ];
		varying vec4 vSpotShadowCoord[ NUM_SPOT_LIGHTS ];

	#endif

	#if NUM_POINT_LIGHTS > 0

		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHTS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHTS ];

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): uniforms for area light shadows

	#endif
	*/

#endif
`,Pu=`
#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

		vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * worldPosition;

	}

	#endif

	#if NUM_SPOT_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {

		vSpotShadowCoord[ i ] = spotShadowMatrix[ i ] * worldPosition;

	}

	#endif

	#if NUM_POINT_LIGHTS > 0

	#pragma unroll_loop
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {

		vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * worldPosition;

	}

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update vAreaShadowCoord with area light info

	#endif
	*/

#endif
`,Cu=`
float getShadowMask() {

	float shadow = 1.0;

	#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHTS > 0

	DirectionalLight directionalLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {

		directionalLight = directionalLights[ i ];
		shadow *= bool( directionalLight.shadow ) ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;

	}

	#endif

	#if NUM_SPOT_LIGHTS > 0

	SpotLight spotLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {

		spotLight = spotLights[ i ];
		shadow *= bool( spotLight.shadow ) ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowBias, spotLight.shadowRadius, vSpotShadowCoord[ i ] ) : 1.0;

	}

	#endif

	#if NUM_POINT_LIGHTS > 0

	PointLight pointLight;

	#pragma unroll_loop
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {

		pointLight = pointLights[ i ];
		shadow *= bool( pointLight.shadow ) ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;

	}

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update shadow for Area light

	#endif
	*/

	#endif

	return shadow;

}
`,Iu=`
#ifdef USE_SKINNING

	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );

#endif
`,Du=`
#ifdef USE_SKINNING

	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;

	#ifdef BONE_TEXTURE

		uniform sampler2D boneTexture;
		uniform int boneTextureSize;

		mat4 getBoneMatrix( const in float i ) {

			float j = i * 4.0;
			float x = mod( j, float( boneTextureSize ) );
			float y = floor( j / float( boneTextureSize ) );

			float dx = 1.0 / float( boneTextureSize );
			float dy = 1.0 / float( boneTextureSize );

			y = dy * ( y + 0.5 );

			vec4 v1 = texture2D( boneTexture, vec2( dx * ( x + 0.5 ), y ) );
			vec4 v2 = texture2D( boneTexture, vec2( dx * ( x + 1.5 ), y ) );
			vec4 v3 = texture2D( boneTexture, vec2( dx * ( x + 2.5 ), y ) );
			vec4 v4 = texture2D( boneTexture, vec2( dx * ( x + 3.5 ), y ) );

			mat4 bone = mat4( v1, v2, v3, v4 );

			return bone;

		}

	#else

		uniform mat4 boneMatrices[ MAX_BONES ];

		mat4 getBoneMatrix( const in float i ) {

			mat4 bone = boneMatrices[ int(i) ];
			return bone;

		}

	#endif

#endif
`,Ou=`
#ifdef USE_SKINNING

	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );

	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;

	transformed = ( bindMatrixInverse * skinned ).xyz;

#endif
`,Fu=`
#ifdef USE_SKINNING

	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix  = bindMatrixInverse * skinMatrix * bindMatrix;

	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;

#endif
`,Uu=`
float specularStrength;

#ifdef USE_SPECULARMAP

	vec4 texelSpecular = texture2D( specularMap, vUv );
	specularStrength = texelSpecular.r;

#else

	specularStrength = 1.0;

#endif
`,Bu=`
#ifdef USE_SPECULARMAP

	uniform sampler2D specularMap;

#endif
`,Nu=`
#if defined( TONE_MAPPING )

  gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );

#endif
`,Gu=`
#ifndef saturate
	#define saturate(a) clamp( a, 0.0, 1.0 )
#endif

uniform float toneMappingExposure;
uniform float toneMappingWhitePoint;

// exposure only
vec3 LinearToneMapping( vec3 color ) {

	return toneMappingExposure * color;

}

// source: https://www.cs.utah.edu/~reinhard/cdrom/
vec3 ReinhardToneMapping( vec3 color ) {

	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );

}

// source: http://filmicgames.com/archives/75
#define Uncharted2Helper( x ) max( ( ( x * ( 0.15 * x + 0.10 * 0.50 ) + 0.20 * 0.02 ) / ( x * ( 0.15 * x + 0.50 ) + 0.20 * 0.30 ) ) - 0.02 / 0.30, vec3( 0.0 ) )
vec3 Uncharted2ToneMapping( vec3 color ) {

	// John Hable's filmic operator from Uncharted 2 video game
	color *= toneMappingExposure;
	return saturate( Uncharted2Helper( color ) / Uncharted2Helper( vec3( toneMappingWhitePoint ) ) );

}

// source: http://filmicgames.com/archives/75
vec3 OptimizedCineonToneMapping( vec3 color ) {

	// optimized filmic operator by Jim Hejl and Richard Burgess-Dawson
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );

}

// source: https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilmicToneMapping( vec3 color ) {

	color *= toneMappingExposure;
	return saturate( ( color * ( 2.51 * color + 0.03 ) ) / ( color * ( 2.43 * color + 0.59 ) + 0.14 ) );

}
`,zu=`
#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP ) || defined( USE_ALPHAMAP ) || defined( USE_EMISSIVEMAP ) || defined( USE_ROUGHNESSMAP ) || defined( USE_METALNESSMAP )

	varying vec2 vUv;

#endif
`,Hu=`
#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP ) || defined( USE_ALPHAMAP ) || defined( USE_EMISSIVEMAP ) || defined( USE_ROUGHNESSMAP ) || defined( USE_METALNESSMAP )

	varying vec2 vUv;
	uniform mat3 uvTransform;

#endif
`,Vu=`
#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP ) || defined( USE_ALPHAMAP ) || defined( USE_EMISSIVEMAP ) || defined( USE_ROUGHNESSMAP ) || defined( USE_METALNESSMAP )

	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;

#endif
`,ku=`
#if defined( USE_LIGHTMAP ) || defined( USE_AOMAP )

	varying vec2 vUv2;

#endif
`,Wu=`
#if defined( USE_LIGHTMAP ) || defined( USE_AOMAP )

	attribute vec2 uv2;
	varying vec2 vUv2;

#endif
`,Xu=`
#if defined( USE_LIGHTMAP ) || defined( USE_AOMAP )

	vUv2 = uv2;

#endif
`,ju=`
#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP )

	vec4 worldPosition = modelMatrix * vec4( transformed, 1.0 );

#endif
`,qu=`
uniform sampler2D t2D;

varying vec2 vUv;

void main() {

	vec4 texColor = texture2D( t2D, vUv );

	gl_FragColor = mapTexelToLinear( texColor );

	#include <tonemapping_fragment>
	#include <encodings_fragment>

}
`,Yu=`
varying vec2 vUv;
uniform mat3 uvTransform;

void main() {

	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;

	gl_Position = vec4( position.xy, 1.0, 1.0 );

}
`,Zu=`
uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;

varying vec3 vWorldDirection;

void main() {

	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );

	gl_FragColor = mapTexelToLinear( texColor );
	gl_FragColor.a *= opacity;

	#include <tonemapping_fragment>
	#include <encodings_fragment>

}
`,Ju=`
varying vec3 vWorldDirection;

#include <common>

void main() {

	vWorldDirection = transformDirection( position, modelMatrix );

	#include <begin_vertex>
	#include <project_vertex>

	gl_Position.z = gl_Position.w; // set z to camera.far

}
`,Qu=`
#if DEPTH_PACKING == 3200

	uniform float opacity;

#endif

#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( 1.0 );

	#if DEPTH_PACKING == 3200

		diffuseColor.a = opacity;

	#endif

	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>

	#include <logdepthbuf_fragment>

	#if DEPTH_PACKING == 3200

		gl_FragColor = vec4( vec3( 1.0 - gl_FragCoord.z ), opacity );

	#elif DEPTH_PACKING == 3201

		gl_FragColor = packDepthToRGBA( gl_FragCoord.z );

	#endif

}
`,Ku=`
#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>

	#include <skinbase_vertex>

	#ifdef USE_DISPLACEMENTMAP

		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>

	#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>

}
`,$u=`
#define DISTANCE

uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;

#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <clipping_planes_pars_fragment>

void main () {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( 1.0 );

	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>

	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist ); // clamp to [ 0, 1 ]

	gl_FragColor = packDepthToRGBA( dist );

}
`,el=`
#define DISTANCE

varying vec3 vWorldPosition;

#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>

	#include <skinbase_vertex>

	#ifdef USE_DISPLACEMENTMAP

		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>

	#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>

	vWorldPosition = worldPosition.xyz;

}
`,tl=`
uniform sampler2D tEquirect;

varying vec3 vWorldDirection;

#include <common>

void main() {

	vec3 direction = normalize( vWorldDirection );

	vec2 sampleUV;

	sampleUV.y = asin( clamp( direction.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;

	sampleUV.x = atan( direction.z, direction.x ) * RECIPROCAL_PI2 + 0.5;

	vec4 texColor = texture2D( tEquirect, sampleUV );

	gl_FragColor = mapTexelToLinear( texColor );

	#include <tonemapping_fragment>
	#include <encodings_fragment>

}
`,rl=`
varying vec3 vWorldDirection;

#include <common>

void main() {

	vWorldDirection = transformDirection( position, modelMatrix );

	#include <begin_vertex>
	#include <project_vertex>

}
`,il=`
uniform vec3 diffuse;
uniform float opacity;

uniform float dashSize;
uniform float totalSize;

varying float vLineDistance;

#include <common>
#include <color_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	if ( mod( vLineDistance, totalSize ) > dashSize ) {

		discard;

	}

	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );

	#include <logdepthbuf_fragment>
	#include <color_fragment>

	outgoingLight = diffuseColor.rgb; // simple shader

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <premultiplied_alpha_fragment>
	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>

}
`,nl=`
uniform float scale;
attribute float lineDistance;

varying float vLineDistance;

#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <color_vertex>

	vLineDistance = scale * lineDistance;

	vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );
	gl_Position = projectionMatrix * mvPosition;

	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>

}
`,al=`
uniform vec3 diffuse;
uniform float opacity;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <uv2_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( diffuse, opacity );

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <specularmap_fragment>

	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );

	// accumulation (baked indirect lighting only)
	#ifdef USE_LIGHTMAP

		reflectedLight.indirectDiffuse += texture2D( lightMap, vUv2 ).xyz * lightMapIntensity;

	#else

		reflectedLight.indirectDiffuse += vec3( 1.0 );

	#endif

	// modulation
	#include <aomap_fragment>

	reflectedLight.indirectDiffuse *= diffuseColor.rgb;

	vec3 outgoingLight = reflectedLight.indirectDiffuse;

	#include <envmap_fragment>

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <premultiplied_alpha_fragment>
	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>

}
`,sl=`
#include <common>
#include <uv_pars_vertex>
#include <uv2_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>
	#include <uv2_vertex>
	#include <color_vertex>
	#include <skinbase_vertex>

	#ifdef USE_ENVMAP

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

	#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>

	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>

}
`,ol=`
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;

varying vec3 vLightFront;

#ifdef DOUBLE_SIDED

	varying vec3 vLightBack;

#endif

#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <uv2_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <fog_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <specularmap_fragment>
	#include <emissivemap_fragment>

	// accumulation
	reflectedLight.indirectDiffuse = getAmbientLightIrradiance( ambientLightColor );

	#include <lightmap_fragment>

	reflectedLight.indirectDiffuse *= BRDF_Diffuse_Lambert( diffuseColor.rgb );

	#ifdef DOUBLE_SIDED

		reflectedLight.directDiffuse = ( gl_FrontFacing ) ? vLightFront : vLightBack;

	#else

		reflectedLight.directDiffuse = vLightFront;

	#endif

	reflectedLight.directDiffuse *= BRDF_Diffuse_Lambert( diffuseColor.rgb ) * getShadowMask();

	// modulation
	#include <aomap_fragment>

	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;

	#include <envmap_fragment>

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>

}
`,hl=`
#define LAMBERT

varying vec3 vLightFront;

#ifdef DOUBLE_SIDED

	varying vec3 vLightBack;

#endif

#include <common>
#include <uv_pars_vertex>
#include <uv2_pars_vertex>
#include <envmap_pars_vertex>
#include <bsdfs>
#include <lights_pars_begin>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>
	#include <uv2_vertex>
	#include <color_vertex>

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>

	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <lights_lambert_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>

}
`,cl=`
#define MATCAP

uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;

varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>

#include <fog_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( diffuse, opacity );

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>

	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5; // 0.495 to remove artifacts caused by undersized matcap disks

	#ifdef USE_MATCAP

		vec4 matcapColor = texture2D( matcap, uv );
		matcapColor = matcapTexelToLinear( matcapColor );

	#else

		vec4 matcapColor = vec4( 1.0 );

	#endif

	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <premultiplied_alpha_fragment>
	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>

}
`,ul=`
#define MATCAP

varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>

#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

	#ifndef FLAT_SHADED // Normal computed with derivatives when FLAT_SHADED

		vNormal = normalize( transformedNormal );

	#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>

	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>

	vViewPosition = - mvPosition.xyz;

}
`,ll=`
#define PHONG

uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;

#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <uv2_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>

	// accumulation
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>

	// modulation
	#include <aomap_fragment>

	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;

	#include <envmap_fragment>

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>

}
`,fl=`
#define PHONG

varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <uv_pars_vertex>
#include <uv2_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>
	#include <uv2_vertex>
	#include <color_vertex>

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

#ifndef FLAT_SHADED // Normal computed with derivatives when FLAT_SHADED

	vNormal = normalize( transformedNormal );

#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>

	vViewPosition = - mvPosition.xyz;

	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>

}
`,dl=`
#define PHYSICAL

uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;

#ifndef STANDARD
	uniform float clearCoat;
	uniform float clearCoatRoughness;
#endif

varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <uv2_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <bsdfs>
#include <cube_uv_reflection_fragment>
#include <envmap_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <lights_physical_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>

	// accumulation
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>

	// modulation
	#include <aomap_fragment>

	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>

}
`,pl=`
#define PHYSICAL

varying vec3 vViewPosition;

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <common>
#include <uv_pars_vertex>
#include <uv2_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>
	#include <uv2_vertex>
	#include <color_vertex>

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

#ifndef FLAT_SHADED // Normal computed with derivatives when FLAT_SHADED

	vNormal = normalize( transformedNormal );

#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>

	vViewPosition = - mvPosition.xyz;

	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>

}
`,ml=`
#define NORMAL

uniform float opacity;

#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || ( defined( USE_NORMALMAP ) && ! defined( OBJECTSPACE_NORMALMAP ) )

	varying vec3 vViewPosition;

#endif

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <packing>
#include <uv_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>

void main() {

	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>

	gl_FragColor = vec4( packNormalToRGB( normal ), opacity );

}
`,vl=`
#define NORMAL

#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || ( defined( USE_NORMALMAP ) && ! defined( OBJECTSPACE_NORMALMAP ) )

	varying vec3 vViewPosition;

#endif

#ifndef FLAT_SHADED

	varying vec3 vNormal;

#endif

#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>

void main() {

	#include <uv_vertex>

	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>

#ifndef FLAT_SHADED // Normal computed with derivatives when FLAT_SHADED

	vNormal = normalize( transformedNormal );

#endif

	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>

#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || ( defined( USE_NORMALMAP ) && ! defined( OBJECTSPACE_NORMALMAP ) )

	vViewPosition = - mvPosition.xyz;

#endif

}
`,gl=`
uniform vec3 diffuse;
uniform float opacity;

#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );

	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>

	outgoingLight = diffuseColor.rgb;

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <premultiplied_alpha_fragment>
	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>

}
`,yl=`
uniform float size;
uniform float scale;

#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <color_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>

	gl_PointSize = size;

	#ifdef USE_SIZEATTENUATION

		bool isPerspective = ( projectionMatrix[ 2 ][ 3 ] == - 1.0 );

		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );

	#endif

	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>

}
`,xl=`
uniform vec3 color;
uniform float opacity;

#include <common>
#include <packing>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>

void main() {

	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );

	#include <fog_fragment>

}
`,_l=`
#include <fog_pars_vertex>
#include <shadowmap_pars_vertex>

void main() {

	#include <begin_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>

}
`,wl=`
uniform vec3 diffuse;
uniform float opacity;

#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>

void main() {

	#include <clipping_planes_fragment>

	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );

	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphatest_fragment>

	outgoingLight = diffuseColor.rgb;

	gl_FragColor = vec4( outgoingLight, diffuseColor.a );

	#include <tonemapping_fragment>
	#include <encodings_fragment>
	#include <fog_fragment>

}
`,bl=`
uniform float rotation;
uniform vec2 center;

#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

void main() {

	#include <uv_vertex>

	vec4 mvPosition = modelViewMatrix * vec4( 0.0, 0.0, 0.0, 1.0 );

	vec2 scale;
	scale.x = length( vec3( modelMatrix[ 0 ].x, modelMatrix[ 0 ].y, modelMatrix[ 0 ].z ) );
	scale.y = length( vec3( modelMatrix[ 1 ].x, modelMatrix[ 1 ].y, modelMatrix[ 1 ].z ) );

	#ifndef USE_SIZEATTENUATION

		bool isPerspective = ( projectionMatrix[ 2 ][ 3 ] == - 1.0 );

		if ( isPerspective ) scale *= - mvPosition.z;

	#endif

	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;

	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;

	mvPosition.xy += rotatedPosition;

	gl_Position = projectionMatrix * mvPosition;

	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>

}
`;var Te={alphamap_fragment:fc,alphamap_pars_fragment:dc,alphatest_fragment:pc,aomap_fragment:mc,aomap_pars_fragment:vc,begin_vertex:gc,beginnormal_vertex:yc,bsdfs:xc,bumpmap_pars_fragment:_c,clipping_planes_fragment:wc,clipping_planes_pars_fragment:bc,clipping_planes_pars_vertex:Mc,clipping_planes_vertex:Ec,color_fragment:Tc,color_pars_fragment:Sc,color_pars_vertex:Ac,color_vertex:Lc,common:Rc,cube_uv_reflection_fragment:Pc,defaultnormal_vertex:Cc,displacementmap_pars_vertex:Ic,displacementmap_vertex:Dc,emissivemap_fragment:Oc,emissivemap_pars_fragment:Fc,encodings_fragment:Uc,encodings_pars_fragment:Bc,envmap_fragment:Nc,envmap_pars_fragment:Gc,envmap_pars_vertex:zc,envmap_physical_pars_fragment:Qc,envmap_vertex:Hc,fog_vertex:Vc,fog_pars_vertex:kc,fog_fragment:Wc,fog_pars_fragment:Xc,gradientmap_pars_fragment:jc,lightmap_fragment:qc,lightmap_pars_fragment:Yc,lights_lambert_vertex:Zc,lights_pars_begin:Jc,lights_phong_fragment:Kc,lights_phong_pars_fragment:$c,lights_physical_fragment:eu,lights_physical_pars_fragment:tu,lights_fragment_begin:ru,lights_fragment_maps:iu,lights_fragment_end:nu,logdepthbuf_fragment:au,logdepthbuf_pars_fragment:su,logdepthbuf_pars_vertex:ou,logdepthbuf_vertex:hu,map_fragment:cu,map_pars_fragment:uu,map_particle_fragment:lu,map_particle_pars_fragment:fu,metalnessmap_fragment:du,metalnessmap_pars_fragment:pu,morphnormal_vertex:mu,morphtarget_pars_vertex:vu,morphtarget_vertex:gu,normal_fragment_begin:yu,normal_fragment_maps:xu,normalmap_pars_fragment:_u,packing:wu,premultiplied_alpha_fragment:bu,project_vertex:Mu,dithering_fragment:Eu,dithering_pars_fragment:Tu,roughnessmap_fragment:Su,roughnessmap_pars_fragment:Au,shadowmap_pars_fragment:Lu,shadowmap_pars_vertex:Ru,shadowmap_vertex:Pu,shadowmask_pars_fragment:Cu,skinbase_vertex:Iu,skinning_pars_vertex:Du,skinning_vertex:Ou,skinnormal_vertex:Fu,specularmap_fragment:Uu,specularmap_pars_fragment:Bu,tonemapping_fragment:Nu,tonemapping_pars_fragment:Gu,uv_pars_fragment:zu,uv_pars_vertex:Hu,uv_vertex:Vu,uv2_pars_fragment:ku,uv2_pars_vertex:Wu,uv2_vertex:Xu,worldpos_vertex:ju,background_frag:qu,background_vert:Yu,cube_frag:Zu,cube_vert:Ju,depth_frag:Qu,depth_vert:Ku,distanceRGBA_frag:$u,distanceRGBA_vert:el,equirect_frag:tl,equirect_vert:rl,linedashed_frag:il,linedashed_vert:nl,meshbasic_frag:al,meshbasic_vert:sl,meshlambert_frag:ol,meshlambert_vert:hl,meshmatcap_frag:cl,meshmatcap_vert:ul,meshphong_frag:ll,meshphong_vert:fl,meshphysical_frag:dl,meshphysical_vert:pl,normal_frag:ml,normal_vert:vl,points_frag:gl,points_vert:yl,shadow_frag:xl,shadow_vert:_l,sprite_frag:wl,sprite_vert:bl};function ri(e){var t={};for(var r in e){t[r]={};for(var i in e[r]){var n=e[r][i];n&&(n.isColor||n.isMatrix3||n.isMatrix4||n.isVector2||n.isVector3||n.isVector4||n.isTexture)?t[r][i]=n.clone():Array.isArray(n)?t[r][i]=n.slice():t[r][i]=n}}return t}function yt(e){for(var t={},r=0;r<e.length;r++){var i=ri(e[r]);for(var n in i)t[n]=i[n]}return t}var Ml={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074};function oe(e,t,r){return t===void 0&&r===void 0?this.set(e):this.setRGB(e,t,r)}Object.assign(oe.prototype,{isColor:!0,r:1,g:1,b:1,set:function(e){return e&&e.isColor?this.copy(e):typeof e=="number"?this.setHex(e):typeof e=="string"&&this.setStyle(e),this},setScalar:function(e){return this.r=e,this.g=e,this.b=e,this},setHex:function(e){return e=Math.floor(e),this.r=(e>>16&255)/255,this.g=(e>>8&255)/255,this.b=(e&255)/255,this},setRGB:function(e,t,r){return this.r=e,this.g=t,this.b=r,this},setHSL:function(){function e(t,r,i){return i<0&&(i+=1),i>1&&(i-=1),i<1/6?t+(r-t)*6*i:i<1/2?r:i<2/3?t+(r-t)*6*(2/3-i):t}return function(r,i,n){if(r=ge.euclideanModulo(r,1),i=ge.clamp(i,0,1),n=ge.clamp(n,0,1),i===0)this.r=this.g=this.b=n;else{var a=n<=.5?n*(1+i):n+i-n*i,s=2*n-a;this.r=e(s,a,r+1/3),this.g=e(s,a,r),this.b=e(s,a,r-1/3)}return this}}(),setStyle:function(e){function t(l){l!==void 0&&parseFloat(l)<1&&console.warn("THREE.Color: Alpha component of "+e+" will be ignored.")}var r;if(r=/^((?:rgb|hsl)a?)\(\s*([^\)]*)\)/.exec(e)){var i,n=r[1],a=r[2];switch(n){case"rgb":case"rgba":if(i=/^(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(,\s*([0-9]*\.?[0-9]+)\s*)?$/.exec(a))return this.r=Math.min(255,parseInt(i[1],10))/255,this.g=Math.min(255,parseInt(i[2],10))/255,this.b=Math.min(255,parseInt(i[3],10))/255,t(i[5]),this;if(i=/^(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(,\s*([0-9]*\.?[0-9]+)\s*)?$/.exec(a))return this.r=Math.min(100,parseInt(i[1],10))/100,this.g=Math.min(100,parseInt(i[2],10))/100,this.b=Math.min(100,parseInt(i[3],10))/100,t(i[5]),this;break;case"hsl":case"hsla":if(i=/^([0-9]*\.?[0-9]+)\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(,\s*([0-9]*\.?[0-9]+)\s*)?$/.exec(a)){var s=parseFloat(i[1])/360,o=parseInt(i[2],10)/100,h=parseInt(i[3],10)/100;return t(i[5]),this.setHSL(s,o,h)}break}}else if(r=/^\#([A-Fa-f0-9]+)$/.exec(e)){var c=r[1],u=c.length;if(u===3)return this.r=parseInt(c.charAt(0)+c.charAt(0),16)/255,this.g=parseInt(c.charAt(1)+c.charAt(1),16)/255,this.b=parseInt(c.charAt(2)+c.charAt(2),16)/255,this;if(u===6)return this.r=parseInt(c.charAt(0)+c.charAt(1),16)/255,this.g=parseInt(c.charAt(2)+c.charAt(3),16)/255,this.b=parseInt(c.charAt(4)+c.charAt(5),16)/255,this}if(e&&e.length>0){var c=Ml[e];c!==void 0?this.setHex(c):console.warn("THREE.Color: Unknown color "+e)}return this},clone:function(){return new this.constructor(this.r,this.g,this.b)},copy:function(e){return this.r=e.r,this.g=e.g,this.b=e.b,this},copyGammaToLinear:function(e,t){return t===void 0&&(t=2),this.r=Math.pow(e.r,t),this.g=Math.pow(e.g,t),this.b=Math.pow(e.b,t),this},copyLinearToGamma:function(e,t){t===void 0&&(t=2);var r=t>0?1/t:1;return this.r=Math.pow(e.r,r),this.g=Math.pow(e.g,r),this.b=Math.pow(e.b,r),this},convertGammaToLinear:function(e){return this.copyGammaToLinear(this,e),this},convertLinearToGamma:function(e){return this.copyLinearToGamma(this,e),this},copySRGBToLinear:function(){function e(t){return t<.04045?t*.0773993808:Math.pow(t*.9478672986+.0521327014,2.4)}return function(r){return this.r=e(r.r),this.g=e(r.g),this.b=e(r.b),this}}(),copyLinearToSRGB:function(){function e(t){return t<.0031308?t*12.92:1.055*Math.pow(t,.41666)-.055}return function(r){return this.r=e(r.r),this.g=e(r.g),this.b=e(r.b),this}}(),convertSRGBToLinear:function(){return this.copySRGBToLinear(this),this},convertLinearToSRGB:function(){return this.copyLinearToSRGB(this),this},getHex:function(){return this.r*255<<16^this.g*255<<8^this.b*255<<0},getHexString:function(){return("000000"+this.getHex().toString(16)).slice(-6)},getHSL:function(e){e===void 0&&(console.warn("THREE.Color: .getHSL() target is now required"),e={h:0,s:0,l:0});var t=this.r,r=this.g,i=this.b,n=Math.max(t,r,i),a=Math.min(t,r,i),s,o,h=(a+n)/2;if(a===n)s=0,o=0;else{var c=n-a;switch(o=h<=.5?c/(n+a):c/(2-n-a),n){case t:s=(r-i)/c+(r<i?6:0);break;case r:s=(i-t)/c+2;break;case i:s=(t-r)/c+4;break}s/=6}return e.h=s,e.s=o,e.l=h,e},getStyle:function(){return"rgb("+(this.r*255|0)+","+(this.g*255|0)+","+(this.b*255|0)+")"},offsetHSL:function(){var e={};return function(t,r,i){return this.getHSL(e),e.h+=t,e.s+=r,e.l+=i,this.setHSL(e.h,e.s,e.l),this}}(),add:function(e){return this.r+=e.r,this.g+=e.g,this.b+=e.b,this},addColors:function(e,t){return this.r=e.r+t.r,this.g=e.g+t.g,this.b=e.b+t.b,this},addScalar:function(e){return this.r+=e,this.g+=e,this.b+=e,this},sub:function(e){return this.r=Math.max(0,this.r-e.r),this.g=Math.max(0,this.g-e.g),this.b=Math.max(0,this.b-e.b),this},multiply:function(e){return this.r*=e.r,this.g*=e.g,this.b*=e.b,this},multiplyScalar:function(e){return this.r*=e,this.g*=e,this.b*=e,this},lerp:function(e,t){return this.r+=(e.r-this.r)*t,this.g+=(e.g-this.g)*t,this.b+=(e.b-this.b)*t,this},lerpHSL:function(){var e={h:0,s:0,l:0},t={h:0,s:0,l:0};return function(i,n){this.getHSL(e),i.getHSL(t);var a=ge.lerp(e.h,t.h,n),s=ge.lerp(e.s,t.s,n),o=ge.lerp(e.l,t.l,n);return this.setHSL(a,s,o),this}}(),equals:function(e){return e.r===this.r&&e.g===this.g&&e.b===this.b},fromArray:function(e,t){return t===void 0&&(t=0),this.r=e[t],this.g=e[t+1],this.b=e[t+2],this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this.r,e[t+1]=this.g,e[t+2]=this.b,e},toJSON:function(){return this.getHex()}});var ae={common:{diffuse:{value:new oe(15658734)},opacity:{value:1},map:{value:null},uvTransform:{value:new nt},alphaMap:{value:null}},specularmap:{specularMap:{value:null}},envmap:{envMap:{value:null},flipEnvMap:{value:-1},reflectivity:{value:1},refractionRatio:{value:.98},maxMipLevel:{value:0}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1}},emissivemap:{emissiveMap:{value:null}},bumpmap:{bumpMap:{value:null},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalScale:{value:new z(1,1)}},displacementmap:{displacementMap:{value:null},displacementScale:{value:1},displacementBias:{value:0}},roughnessmap:{roughnessMap:{value:null}},metalnessmap:{metalnessMap:{value:null}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new oe(16777215)}},lights:{ambientLightColor:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{},shadow:{},shadowBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{},shadow:{},shadowBias:{},shadowRadius:{},shadowMapSize:{}}},spotShadowMap:{value:[]},spotShadowMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{},shadow:{},shadowBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}}},points:{diffuse:{value:new oe(15658734)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},uvTransform:{value:new nt}},sprite:{diffuse:{value:new oe(15658734)},opacity:{value:1},center:{value:new z(.5,.5)},rotation:{value:0},map:{value:null},uvTransform:{value:new nt}}},kt={basic:{uniforms:yt([ae.common,ae.specularmap,ae.envmap,ae.aomap,ae.lightmap,ae.fog]),vertexShader:Te.meshbasic_vert,fragmentShader:Te.meshbasic_frag},lambert:{uniforms:yt([ae.common,ae.specularmap,ae.envmap,ae.aomap,ae.lightmap,ae.emissivemap,ae.fog,ae.lights,{emissive:{value:new oe(0)}}]),vertexShader:Te.meshlambert_vert,fragmentShader:Te.meshlambert_frag},phong:{uniforms:yt([ae.common,ae.specularmap,ae.envmap,ae.aomap,ae.lightmap,ae.emissivemap,ae.bumpmap,ae.normalmap,ae.displacementmap,ae.gradientmap,ae.fog,ae.lights,{emissive:{value:new oe(0)},specular:{value:new oe(1118481)},shininess:{value:30}}]),vertexShader:Te.meshphong_vert,fragmentShader:Te.meshphong_frag},standard:{uniforms:yt([ae.common,ae.envmap,ae.aomap,ae.lightmap,ae.emissivemap,ae.bumpmap,ae.normalmap,ae.displacementmap,ae.roughnessmap,ae.metalnessmap,ae.fog,ae.lights,{emissive:{value:new oe(0)},roughness:{value:.5},metalness:{value:.5},envMapIntensity:{value:1}}]),vertexShader:Te.meshphysical_vert,fragmentShader:Te.meshphysical_frag},matcap:{uniforms:yt([ae.common,ae.bumpmap,ae.normalmap,ae.displacementmap,ae.fog,{matcap:{value:null}}]),vertexShader:Te.meshmatcap_vert,fragmentShader:Te.meshmatcap_frag},points:{uniforms:yt([ae.points,ae.fog]),vertexShader:Te.points_vert,fragmentShader:Te.points_frag},dashed:{uniforms:yt([ae.common,ae.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Te.linedashed_vert,fragmentShader:Te.linedashed_frag},depth:{uniforms:yt([ae.common,ae.displacementmap]),vertexShader:Te.depth_vert,fragmentShader:Te.depth_frag},normal:{uniforms:yt([ae.common,ae.bumpmap,ae.normalmap,ae.displacementmap,{opacity:{value:1}}]),vertexShader:Te.normal_vert,fragmentShader:Te.normal_frag},sprite:{uniforms:yt([ae.sprite,ae.fog]),vertexShader:Te.sprite_vert,fragmentShader:Te.sprite_frag},background:{uniforms:{uvTransform:{value:new nt},t2D:{value:null}},vertexShader:Te.background_vert,fragmentShader:Te.background_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Te.cube_vert,fragmentShader:Te.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Te.equirect_vert,fragmentShader:Te.equirect_frag},distanceRGBA:{uniforms:yt([ae.common,ae.displacementmap,{referencePosition:{value:new b},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Te.distanceRGBA_vert,fragmentShader:Te.distanceRGBA_frag},shadow:{uniforms:yt([ae.lights,ae.fog,{color:{value:new oe(0)},opacity:{value:1}}]),vertexShader:Te.shadow_vert,fragmentShader:Te.shadow_frag}};kt.physical={uniforms:yt([kt.standard.uniforms,{clearCoat:{value:0},clearCoatRoughness:{value:0}}]),vertexShader:Te.meshphysical_vert,fragmentShader:Te.meshphysical_frag};function Qa(){var e=null,t=!1,r=null;function i(n,a){t!==!1&&(r(n,a),e.requestAnimationFrame(i))}return{start:function(){t!==!0&&r!==null&&(e.requestAnimationFrame(i),t=!0)},stop:function(){t=!1},setAnimationLoop:function(n){r=n},setContext:function(n){e=n}}}function El(e){var t=new WeakMap;function r(o,h){var c=o.array,u=o.dynamic?e.DYNAMIC_DRAW:e.STATIC_DRAW,l=e.createBuffer();e.bindBuffer(h,l),e.bufferData(h,c,u),o.onUploadCallback();var f=e.FLOAT;return c instanceof Float32Array?f=e.FLOAT:c instanceof Float64Array?console.warn("THREE.WebGLAttributes: Unsupported data buffer format: Float64Array."):c instanceof Uint16Array?f=e.UNSIGNED_SHORT:c instanceof Int16Array?f=e.SHORT:c instanceof Uint32Array?f=e.UNSIGNED_INT:c instanceof Int32Array?f=e.INT:c instanceof Int8Array?f=e.BYTE:c instanceof Uint8Array&&(f=e.UNSIGNED_BYTE),{buffer:l,type:f,bytesPerElement:c.BYTES_PER_ELEMENT,version:o.version}}function i(o,h,c){var u=h.array,l=h.updateRange;e.bindBuffer(c,o),h.dynamic===!1?e.bufferData(c,u,e.STATIC_DRAW):l.count===-1?e.bufferSubData(c,0,u):l.count===0?console.error("THREE.WebGLObjects.updateBuffer: dynamic THREE.BufferAttribute marked as needsUpdate but updateRange.count is 0, ensure you are using set methods or updating manually."):(e.bufferSubData(c,l.offset*u.BYTES_PER_ELEMENT,u.subarray(l.offset,l.offset+l.count)),l.count=-1)}function n(o){return o.isInterleavedBufferAttribute&&(o=o.data),t.get(o)}function a(o){o.isInterleavedBufferAttribute&&(o=o.data);var h=t.get(o);h&&(e.deleteBuffer(h.buffer),t.delete(o))}function s(o,h){o.isInterleavedBufferAttribute&&(o=o.data);var c=t.get(o);c===void 0?t.set(o,r(o,h)):c.version<o.version&&(i(c.buffer,o,h),c.version=o.version)}return{get:n,remove:a,update:s}}function en(e,t,r,i,n,a){this.a=e,this.b=t,this.c=r,this.normal=i&&i.isVector3?i:new b,this.vertexNormals=Array.isArray(i)?i:[],this.color=n&&n.isColor?n:new oe,this.vertexColors=Array.isArray(n)?n:[],this.materialIndex=a!==void 0?a:0}Object.assign(en.prototype,{clone:function(){return new this.constructor().copy(this)},copy:function(e){this.a=e.a,this.b=e.b,this.c=e.c,this.normal.copy(e.normal),this.color.copy(e.color),this.materialIndex=e.materialIndex;for(var t=0,r=e.vertexNormals.length;t<r;t++)this.vertexNormals[t]=e.vertexNormals[t].clone();for(var t=0,r=e.vertexColors.length;t<r;t++)this.vertexColors[t]=e.vertexColors[t].clone();return this}});function Xr(e,t,r,i){this._x=e||0,this._y=t||0,this._z=r||0,this._order=i||Xr.DefaultOrder}Xr.RotationOrders=["XYZ","YZX","ZXY","XZY","YXZ","ZYX"];Xr.DefaultOrder="XYZ";Object.defineProperties(Xr.prototype,{x:{get:function(){return this._x},set:function(e){this._x=e,this.onChangeCallback()}},y:{get:function(){return this._y},set:function(e){this._y=e,this.onChangeCallback()}},z:{get:function(){return this._z},set:function(e){this._z=e,this.onChangeCallback()}},order:{get:function(){return this._order},set:function(e){this._order=e,this.onChangeCallback()}}});Object.assign(Xr.prototype,{isEuler:!0,set:function(e,t,r,i){return this._x=e,this._y=t,this._z=r,this._order=i||this._order,this.onChangeCallback(),this},clone:function(){return new this.constructor(this._x,this._y,this._z,this._order)},copy:function(e){return this._x=e._x,this._y=e._y,this._z=e._z,this._order=e._order,this.onChangeCallback(),this},setFromRotationMatrix:function(e,t,r){var i=ge.clamp,n=e.elements,a=n[0],s=n[4],o=n[8],h=n[1],c=n[5],u=n[9],l=n[2],f=n[6],d=n[10];return t=t||this._order,t==="XYZ"?(this._y=Math.asin(i(o,-1,1)),Math.abs(o)<.99999?(this._x=Math.atan2(-u,d),this._z=Math.atan2(-s,a)):(this._x=Math.atan2(f,c),this._z=0)):t==="YXZ"?(this._x=Math.asin(-i(u,-1,1)),Math.abs(u)<.99999?(this._y=Math.atan2(o,d),this._z=Math.atan2(h,c)):(this._y=Math.atan2(-l,a),this._z=0)):t==="ZXY"?(this._x=Math.asin(i(f,-1,1)),Math.abs(f)<.99999?(this._y=Math.atan2(-l,d),this._z=Math.atan2(-s,c)):(this._y=0,this._z=Math.atan2(h,a))):t==="ZYX"?(this._y=Math.asin(-i(l,-1,1)),Math.abs(l)<.99999?(this._x=Math.atan2(f,d),this._z=Math.atan2(h,a)):(this._x=0,this._z=Math.atan2(-s,c))):t==="YZX"?(this._z=Math.asin(i(h,-1,1)),Math.abs(h)<.99999?(this._x=Math.atan2(-u,c),this._y=Math.atan2(-l,a)):(this._x=0,this._y=Math.atan2(o,d))):t==="XZY"?(this._z=Math.asin(-i(s,-1,1)),Math.abs(s)<.99999?(this._x=Math.atan2(f,c),this._y=Math.atan2(o,a)):(this._x=Math.atan2(-u,d),this._y=0)):console.warn("THREE.Euler: .setFromRotationMatrix() given unsupported order: "+t),this._order=t,r!==!1&&this.onChangeCallback(),this},setFromQuaternion:function(){var e=new fe;return function(r,i,n){return e.makeRotationFromQuaternion(r),this.setFromRotationMatrix(e,i,n)}}(),setFromVector3:function(e,t){return this.set(e.x,e.y,e.z,t||this._order)},reorder:function(){var e=new Qe;return function(r){return e.setFromEuler(this),this.setFromQuaternion(e,r)}}(),equals:function(e){return e._x===this._x&&e._y===this._y&&e._z===this._z&&e._order===this._order},fromArray:function(e){return this._x=e[0],this._y=e[1],this._z=e[2],e[3]!==void 0&&(this._order=e[3]),this.onChangeCallback(),this},toArray:function(e,t){return e===void 0&&(e=[]),t===void 0&&(t=0),e[t]=this._x,e[t+1]=this._y,e[t+2]=this._z,e[t+3]=this._order,e},toVector3:function(e){return e?e.set(this._x,this._y,this._z):new b(this._x,this._y,this._z)},onChange:function(e){return this.onChangeCallback=e,this},onChangeCallback:function(){}});function ao(){this.mask=1}Object.assign(ao.prototype,{set:function(e){this.mask=1<<e|0},enable:function(e){this.mask|=1<<e|0},toggle:function(e){this.mask^=1<<e|0},disable:function(e){this.mask&=~(1<<e|0)},test:function(e){return(this.mask&e.mask)!==0}});var Tl=0;function K(){Object.defineProperty(this,"id",{value:Tl++}),this.uuid=ge.generateUUID(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=K.DefaultUp.clone();var e=new b,t=new Xr,r=new Qe,i=new b(1,1,1);function n(){r.setFromEuler(t,!1)}function a(){t.setFromQuaternion(r,void 0,!1)}t.onChange(n),r.onChange(a),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:e},rotation:{configurable:!0,enumerable:!0,value:t},quaternion:{configurable:!0,enumerable:!0,value:r},scale:{configurable:!0,enumerable:!0,value:i},modelViewMatrix:{value:new fe},normalMatrix:{value:new nt}}),this.matrix=new fe,this.matrixWorld=new fe,this.matrixAutoUpdate=K.DefaultMatrixAutoUpdate,this.matrixWorldNeedsUpdate=!1,this.layers=new ao,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.userData={}}K.DefaultUp=new b(0,1,0);K.DefaultMatrixAutoUpdate=!0;K.prototype=Object.assign(Object.create(ar.prototype),{constructor:K,isObject3D:!0,onBeforeRender:function(){},onAfterRender:function(){},applyMatrix:function(e){this.matrix.multiplyMatrices(e,this.matrix),this.matrix.decompose(this.position,this.quaternion,this.scale)},applyQuaternion:function(e){return this.quaternion.premultiply(e),this},setRotationFromAxisAngle:function(e,t){this.quaternion.setFromAxisAngle(e,t)},setRotationFromEuler:function(e){this.quaternion.setFromEuler(e,!0)},setRotationFromMatrix:function(e){this.quaternion.setFromRotationMatrix(e)},setRotationFromQuaternion:function(e){this.quaternion.copy(e)},rotateOnAxis:function(){var e=new Qe;return function(r,i){return e.setFromAxisAngle(r,i),this.quaternion.multiply(e),this}}(),rotateOnWorldAxis:function(){var e=new Qe;return function(r,i){return e.setFromAxisAngle(r,i),this.quaternion.premultiply(e),this}}(),rotateX:function(){var e=new b(1,0,0);return function(r){return this.rotateOnAxis(e,r)}}(),rotateY:function(){var e=new b(0,1,0);return function(r){return this.rotateOnAxis(e,r)}}(),rotateZ:function(){var e=new b(0,0,1);return function(r){return this.rotateOnAxis(e,r)}}(),translateOnAxis:function(){var e=new b;return function(r,i){return e.copy(r).applyQuaternion(this.quaternion),this.position.add(e.multiplyScalar(i)),this}}(),translateX:function(){var e=new b(1,0,0);return function(r){return this.translateOnAxis(e,r)}}(),translateY:function(){var e=new b(0,1,0);return function(r){return this.translateOnAxis(e,r)}}(),translateZ:function(){var e=new b(0,0,1);return function(r){return this.translateOnAxis(e,r)}}(),localToWorld:function(e){return e.applyMatrix4(this.matrixWorld)},worldToLocal:function(){var e=new fe;return function(r){return r.applyMatrix4(e.getInverse(this.matrixWorld))}}(),lookAt:function(){var e=new Qe,t=new fe,r=new b,i=new b;return function(a,s,o){a.isVector3?r.copy(a):r.set(a,s,o);var h=this.parent;this.updateWorldMatrix(!0,!1),i.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?t.lookAt(i,r,this.up):t.lookAt(r,i,this.up),this.quaternion.setFromRotationMatrix(t),h&&(t.extractRotation(h.matrixWorld),e.setFromRotationMatrix(t),this.quaternion.premultiply(e.inverse()))}}(),add:function(e){if(arguments.length>1){for(var t=0;t<arguments.length;t++)this.add(arguments[t]);return this}return e===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",e),this):(e&&e.isObject3D?(e.parent!==null&&e.parent.remove(e),e.parent=this,e.dispatchEvent({type:"added"}),this.children.push(e)):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",e),this)},remove:function(e){if(arguments.length>1){for(var t=0;t<arguments.length;t++)this.remove(arguments[t]);return this}var r=this.children.indexOf(e);return r!==-1&&(e.parent=null,e.dispatchEvent({type:"removed"}),this.children.splice(r,1)),this},getObjectById:function(e){return this.getObjectByProperty("id",e)},getObjectByName:function(e){return this.getObjectByProperty("name",e)},getObjectByProperty:function(e,t){if(this[e]===t)return this;for(var r=0,i=this.children.length;r<i;r++){var n=this.children[r],a=n.getObjectByProperty(e,t);if(a!==void 0)return a}},getWorldPosition:function(e){return e===void 0&&(console.warn("THREE.Object3D: .getWorldPosition() target is now required"),e=new b),this.updateMatrixWorld(!0),e.setFromMatrixPosition(this.matrixWorld)},getWorldQuaternion:function(){var e=new b,t=new b;return function(i){return i===void 0&&(console.warn("THREE.Object3D: .getWorldQuaternion() target is now required"),i=new Qe),this.updateMatrixWorld(!0),this.matrixWorld.decompose(e,i,t),i}}(),getWorldScale:function(){var e=new b,t=new Qe;return function(i){return i===void 0&&(console.warn("THREE.Object3D: .getWorldScale() target is now required"),i=new b),this.updateMatrixWorld(!0),this.matrixWorld.decompose(e,t,i),i}}(),getWorldDirection:function(e){e===void 0&&(console.warn("THREE.Object3D: .getWorldDirection() target is now required"),e=new b),this.updateMatrixWorld(!0);var t=this.matrixWorld.elements;return e.set(t[8],t[9],t[10]).normalize()},raycast:function(){},traverse:function(e){e(this);for(var t=this.children,r=0,i=t.length;r<i;r++)t[r].traverse(e)},traverseVisible:function(e){if(this.visible!==!1){e(this);for(var t=this.children,r=0,i=t.length;r<i;r++)t[r].traverseVisible(e)}},traverseAncestors:function(e){var t=this.parent;t!==null&&(e(t),t.traverseAncestors(e))},updateMatrix:function(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0},updateMatrixWorld:function(e){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||e)&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),this.matrixWorldNeedsUpdate=!1,e=!0);for(var t=this.children,r=0,i=t.length;r<i;r++)t[r].updateMatrixWorld(e)},updateWorldMatrix:function(e,t){var r=this.parent;if(e===!0&&r!==null&&r.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),t===!0)for(var i=this.children,n=0,a=i.length;n<a;n++)i[n].updateWorldMatrix(!1,!0)},toJSON:function(e){var t=e===void 0||typeof e=="string",r={};t&&(e={geometries:{},materials:{},textures:{},images:{},shapes:{}},r.metadata={version:4.5,type:"Object",generator:"Object3D.toJSON"});var i={};i.uuid=this.uuid,i.type=this.type,this.name!==""&&(i.name=this.name),this.castShadow===!0&&(i.castShadow=!0),this.receiveShadow===!0&&(i.receiveShadow=!0),this.visible===!1&&(i.visible=!1),this.frustumCulled===!1&&(i.frustumCulled=!1),this.renderOrder!==0&&(i.renderOrder=this.renderOrder),JSON.stringify(this.userData)!=="{}"&&(i.userData=this.userData),i.layers=this.layers.mask,i.matrix=this.matrix.toArray(),this.matrixAutoUpdate===!1&&(i.matrixAutoUpdate=!1);function n(v,g){return v[g.uuid]===void 0&&(v[g.uuid]=g.toJSON(e)),g.uuid}if(this.isMesh||this.isLine||this.isPoints){i.geometry=n(e.geometries,this.geometry);var a=this.geometry.parameters;if(a!==void 0&&a.shapes!==void 0){var s=a.shapes;if(Array.isArray(s))for(var o=0,h=s.length;o<h;o++){var c=s[o];n(e.shapes,c)}else n(e.shapes,s)}}if(this.material!==void 0)if(Array.isArray(this.material)){for(var u=[],o=0,h=this.material.length;o<h;o++)u.push(n(e.materials,this.material[o]));i.material=u}else i.material=n(e.materials,this.material);if(this.children.length>0){i.children=[];for(var o=0;o<this.children.length;o++)i.children.push(this.children[o].toJSON(e).object)}if(t){var l=m(e.geometries),f=m(e.materials),d=m(e.textures),p=m(e.images),s=m(e.shapes);l.length>0&&(r.geometries=l),f.length>0&&(r.materials=f),d.length>0&&(r.textures=d),p.length>0&&(r.images=p),s.length>0&&(r.shapes=s)}return r.object=i,r;function m(v){var g=[];for(var _ in v){var w=v[_];delete w.metadata,g.push(w)}return g}},clone:function(e){return new this.constructor().copy(this,e)},copy:function(e,t){if(t===void 0&&(t=!0),this.name=e.name,this.up.copy(e.up),this.position.copy(e.position),this.quaternion.copy(e.quaternion),this.scale.copy(e.scale),this.matrix.copy(e.matrix),this.matrixWorld.copy(e.matrixWorld),this.matrixAutoUpdate=e.matrixAutoUpdate,this.matrixWorldNeedsUpdate=e.matrixWorldNeedsUpdate,this.layers.mask=e.layers.mask,this.visible=e.visible,this.castShadow=e.castShadow,this.receiveShadow=e.receiveShadow,this.frustumCulled=e.frustumCulled,this.renderOrder=e.renderOrder,this.userData=JSON.parse(JSON.stringify(e.userData)),t===!0)for(var r=0;r<e.children.length;r++){var i=e.children[r];this.add(i.clone())}return this}});var Sl=0;function de(){Object.defineProperty(this,"id",{value:Sl+=2}),this.uuid=ge.generateUUID(),this.name="",this.type="Geometry",this.vertices=[],this.colors=[],this.faces=[],this.faceVertexUvs=[[]],this.morphTargets=[],this.morphNormals=[],this.skinWeights=[],this.skinIndices=[],this.lineDistances=[],this.boundingBox=null,this.boundingSphere=null,this.elementsNeedUpdate=!1,this.verticesNeedUpdate=!1,this.uvsNeedUpdate=!1,this.normalsNeedUpdate=!1,this.colorsNeedUpdate=!1,this.lineDistancesNeedUpdate=!1,this.groupsNeedUpdate=!1}de.prototype=Object.assign(Object.create(ar.prototype),{constructor:de,isGeometry:!0,applyMatrix:function(e){for(var t=new nt().getNormalMatrix(e),r=0,i=this.vertices.length;r<i;r++){var n=this.vertices[r];n.applyMatrix4(e)}for(var r=0,i=this.faces.length;r<i;r++){var a=this.faces[r];a.normal.applyMatrix3(t).normalize();for(var s=0,o=a.vertexNormals.length;s<o;s++)a.vertexNormals[s].applyMatrix3(t).normalize()}return this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this.verticesNeedUpdate=!0,this.normalsNeedUpdate=!0,this},rotateX:function(){var e=new fe;return function(r){return e.makeRotationX(r),this.applyMatrix(e),this}}(),rotateY:function(){var e=new fe;return function(r){return e.makeRotationY(r),this.applyMatrix(e),this}}(),rotateZ:function(){var e=new fe;return function(r){return e.makeRotationZ(r),this.applyMatrix(e),this}}(),translate:function(){var e=new fe;return function(r,i,n){return e.makeTranslation(r,i,n),this.applyMatrix(e),this}}(),scale:function(){var e=new fe;return function(r,i,n){return e.makeScale(r,i,n),this.applyMatrix(e),this}}(),lookAt:function(){var e=new K;return function(r){e.lookAt(r),e.updateMatrix(),this.applyMatrix(e.matrix)}}(),fromBufferGeometry:function(e){var t=this,r=e.index!==null?e.index.array:void 0,i=e.attributes,n=i.position.array,a=i.normal!==void 0?i.normal.array:void 0,s=i.color!==void 0?i.color.array:void 0,o=i.uv!==void 0?i.uv.array:void 0,h=i.uv2!==void 0?i.uv2.array:void 0;h!==void 0&&(this.faceVertexUvs[1]=[]);for(var c=0,u=0;c<n.length;c+=3,u+=2)t.vertices.push(new b().fromArray(n,c)),s!==void 0&&t.colors.push(new oe().fromArray(s,c));function l(g,_,w,y){var S=s===void 0?[]:[t.colors[g].clone(),t.colors[_].clone(),t.colors[w].clone()],R=a===void 0?[]:[new b().fromArray(a,g*3),new b().fromArray(a,_*3),new b().fromArray(a,w*3)],I=new en(g,_,w,R,S,y);t.faces.push(I),o!==void 0&&t.faceVertexUvs[0].push([new z().fromArray(o,g*2),new z().fromArray(o,_*2),new z().fromArray(o,w*2)]),h!==void 0&&t.faceVertexUvs[1].push([new z().fromArray(h,g*2),new z().fromArray(h,_*2),new z().fromArray(h,w*2)])}var f=e.groups;if(f.length>0)for(var c=0;c<f.length;c++)for(var d=f[c],p=d.start,m=d.count,u=p,v=p+m;u<v;u+=3)r!==void 0?l(r[u],r[u+1],r[u+2],d.materialIndex):l(u,u+1,u+2,d.materialIndex);else if(r!==void 0)for(var c=0;c<r.length;c+=3)l(r[c],r[c+1],r[c+2]);else for(var c=0;c<n.length/3;c+=3)l(c,c+1,c+2);return this.computeFaceNormals(),e.boundingBox!==null&&(this.boundingBox=e.boundingBox.clone()),e.boundingSphere!==null&&(this.boundingSphere=e.boundingSphere.clone()),this},center:function(){var e=new b;return function(){return this.computeBoundingBox(),this.boundingBox.getCenter(e).negate(),this.translate(e.x,e.y,e.z),this}}(),normalize:function(){this.computeBoundingSphere();var e=this.boundingSphere.center,t=this.boundingSphere.radius,r=t===0?1:1/t,i=new fe;return i.set(r,0,0,-r*e.x,0,r,0,-r*e.y,0,0,r,-r*e.z,0,0,0,1),this.applyMatrix(i),this},computeFaceNormals:function(){for(var e=new b,t=new b,r=0,i=this.faces.length;r<i;r++){var n=this.faces[r],a=this.vertices[n.a],s=this.vertices[n.b],o=this.vertices[n.c];e.subVectors(o,s),t.subVectors(a,s),e.cross(t),e.normalize(),n.normal.copy(e)}},computeVertexNormals:function(e){e===void 0&&(e=!0);var t,r,i,n,a,s;for(s=new Array(this.vertices.length),t=0,r=this.vertices.length;t<r;t++)s[t]=new b;if(e){var o,h,c,u=new b,l=new b;for(i=0,n=this.faces.length;i<n;i++)a=this.faces[i],o=this.vertices[a.a],h=this.vertices[a.b],c=this.vertices[a.c],u.subVectors(c,h),l.subVectors(o,h),u.cross(l),s[a.a].add(u),s[a.b].add(u),s[a.c].add(u)}else for(this.computeFaceNormals(),i=0,n=this.faces.length;i<n;i++)a=this.faces[i],s[a.a].add(a.normal),s[a.b].add(a.normal),s[a.c].add(a.normal);for(t=0,r=this.vertices.length;t<r;t++)s[t].normalize();for(i=0,n=this.faces.length;i<n;i++){a=this.faces[i];var f=a.vertexNormals;f.length===3?(f[0].copy(s[a.a]),f[1].copy(s[a.b]),f[2].copy(s[a.c])):(f[0]=s[a.a].clone(),f[1]=s[a.b].clone(),f[2]=s[a.c].clone())}this.faces.length>0&&(this.normalsNeedUpdate=!0)},computeFlatVertexNormals:function(){var e,t,r;for(this.computeFaceNormals(),e=0,t=this.faces.length;e<t;e++){r=this.faces[e];var i=r.vertexNormals;i.length===3?(i[0].copy(r.normal),i[1].copy(r.normal),i[2].copy(r.normal)):(i[0]=r.normal.clone(),i[1]=r.normal.clone(),i[2]=r.normal.clone())}this.faces.length>0&&(this.normalsNeedUpdate=!0)},computeMorphNormals:function(){var e,t,r,i,n;for(r=0,i=this.faces.length;r<i;r++)for(n=this.faces[r],n.__originalFaceNormal?n.__originalFaceNormal.copy(n.normal):n.__originalFaceNormal=n.normal.clone(),n.__originalVertexNormals||(n.__originalVertexNormals=[]),e=0,t=n.vertexNormals.length;e<t;e++)n.__originalVertexNormals[e]?n.__originalVertexNormals[e].copy(n.vertexNormals[e]):n.__originalVertexNormals[e]=n.vertexNormals[e].clone();var a=new de;for(a.faces=this.faces,e=0,t=this.morphTargets.length;e<t;e++){if(!this.morphNormals[e]){this.morphNormals[e]={},this.morphNormals[e].faceNormals=[],this.morphNormals[e].vertexNormals=[];var s=this.morphNormals[e].faceNormals,o=this.morphNormals[e].vertexNormals,c,u;for(r=0,i=this.faces.length;r<i;r++)c=new b,u={a:new b,b:new b,c:new b},s.push(c),o.push(u)}var h=this.morphNormals[e];a.vertices=this.morphTargets[e].vertices,a.computeFaceNormals(),a.computeVertexNormals();var c,u;for(r=0,i=this.faces.length;r<i;r++)n=this.faces[r],c=h.faceNormals[r],u=h.vertexNormals[r],c.copy(n.normal),u.a.copy(n.vertexNormals[0]),u.b.copy(n.vertexNormals[1]),u.c.copy(n.vertexNormals[2])}for(r=0,i=this.faces.length;r<i;r++)n=this.faces[r],n.normal=n.__originalFaceNormal,n.vertexNormals=n.__originalVertexNormals},computeBoundingBox:function(){this.boundingBox===null&&(this.boundingBox=new tr),this.boundingBox.setFromPoints(this.vertices)},computeBoundingSphere:function(){this.boundingSphere===null&&(this.boundingSphere=new Ot),this.boundingSphere.setFromPoints(this.vertices)},merge:function(e,t,r){if(!(e&&e.isGeometry)){console.error("THREE.Geometry.merge(): geometry not an instance of THREE.Geometry.",e);return}var i,n=this.vertices.length,a=this.vertices,s=e.vertices,o=this.faces,h=e.faces,c=this.faceVertexUvs[0],u=e.faceVertexUvs[0],l=this.colors,f=e.colors;r===void 0&&(r=0),t!==void 0&&(i=new nt().getNormalMatrix(t));for(var d=0,p=s.length;d<p;d++){var m=s[d],v=m.clone();t!==void 0&&v.applyMatrix4(t),a.push(v)}for(var d=0,p=f.length;d<p;d++)l.push(f[d].clone());for(d=0,p=h.length;d<p;d++){var g=h[d],_,w,y,S=g.vertexNormals,R=g.vertexColors;_=new en(g.a+n,g.b+n,g.c+n),_.normal.copy(g.normal),i!==void 0&&_.normal.applyMatrix3(i).normalize();for(var I=0,C=S.length;I<C;I++)w=S[I].clone(),i!==void 0&&w.applyMatrix3(i).normalize(),_.vertexNormals.push(w);_.color.copy(g.color);for(var I=0,C=R.length;I<C;I++)y=R[I],_.vertexColors.push(y.clone());_.materialIndex=g.materialIndex+r,o.push(_)}for(d=0,p=u.length;d<p;d++){var A=u[d],O=[];if(A!==void 0){for(var I=0,C=A.length;I<C;I++)O.push(A[I].clone());c.push(O)}}},mergeMesh:function(e){if(!(e&&e.isMesh)){console.error("THREE.Geometry.mergeMesh(): mesh not an instance of THREE.Mesh.",e);return}e.matrixAutoUpdate&&e.updateMatrix(),this.merge(e.geometry,e.matrix)},mergeVertices:function(){var e={},t=[],r=[],i,n,a=4,s=Math.pow(10,a),o,h,c,u,l,f;for(o=0,h=this.vertices.length;o<h;o++)i=this.vertices[o],n=Math.round(i.x*s)+"_"+Math.round(i.y*s)+"_"+Math.round(i.z*s),e[n]===void 0?(e[n]=o,t.push(this.vertices[o]),r[o]=t.length-1):r[o]=r[e[n]];var d=[];for(o=0,h=this.faces.length;o<h;o++){c=this.faces[o],c.a=r[c.a],c.b=r[c.b],c.c=r[c.c],u=[c.a,c.b,c.c];for(var p=0;p<3;p++)if(u[p]===u[(p+1)%3]){d.push(o);break}}for(o=d.length-1;o>=0;o--){var m=d[o];for(this.faces.splice(m,1),l=0,f=this.faceVertexUvs.length;l<f;l++)this.faceVertexUvs[l].splice(m,1)}var v=this.vertices.length-t.length;return this.vertices=t,v},setFromPoints:function(e){this.vertices=[];for(var t=0,r=e.length;t<r;t++){var i=e[t];this.vertices.push(new b(i.x,i.y,i.z||0))}return this},sortFacesByMaterialIndex:function(){for(var e=this.faces,t=e.length,r=0;r<t;r++)e[r]._id=r;function i(c,u){return c.materialIndex-u.materialIndex}e.sort(i);var n=this.faceVertexUvs[0],a=this.faceVertexUvs[1],s,o;n&&n.length===t&&(s=[]),a&&a.length===t&&(o=[]);for(var r=0;r<t;r++){var h=e[r]._id;s&&s.push(n[h]),o&&o.push(a[h])}s&&(this.faceVertexUvs[0]=s),o&&(this.faceVertexUvs[1]=o)},toJSON:function(){var e={metadata:{version:4.5,type:"Geometry",generator:"Geometry.toJSON"}};if(e.uuid=this.uuid,e.type=this.type,this.name!==""&&(e.name=this.name),this.parameters!==void 0){var t=this.parameters;for(var r in t)t[r]!==void 0&&(e[r]=t[r]);return e}for(var i=[],n=0;n<this.vertices.length;n++){var a=this.vertices[n];i.push(a.x,a.y,a.z)}for(var s=[],o=[],h={},c=[],u={},l=[],f={},n=0;n<this.faces.length;n++){var d=this.faces[n],p=!0,m=!1,v=this.faceVertexUvs[0][n]!==void 0,g=d.normal.length()>0,_=d.vertexNormals.length>0,w=d.color.r!==1||d.color.g!==1||d.color.b!==1,y=d.vertexColors.length>0,S=0;if(S=A(S,0,0),S=A(S,1,p),S=A(S,2,m),S=A(S,3,v),S=A(S,4,g),S=A(S,5,_),S=A(S,6,w),S=A(S,7,y),s.push(S),s.push(d.a,d.b,d.c),s.push(d.materialIndex),v){var R=this.faceVertexUvs[0][n];s.push(N(R[0]),N(R[1]),N(R[2]))}if(g&&s.push(O(d.normal)),_){var I=d.vertexNormals;s.push(O(I[0]),O(I[1]),O(I[2]))}if(w&&s.push(F(d.color)),y){var C=d.vertexColors;s.push(F(C[0]),F(C[1]),F(C[2]))}}function A(V,k,G){return G?V|1<<k:V&~(1<<k)}function O(V){var k=V.x.toString()+V.y.toString()+V.z.toString();return h[k]!==void 0||(h[k]=o.length/3,o.push(V.x,V.y,V.z)),h[k]}function F(V){var k=V.r.toString()+V.g.toString()+V.b.toString();return u[k]!==void 0||(u[k]=c.length,c.push(V.getHex())),u[k]}function N(V){var k=V.x.toString()+V.y.toString();return f[k]!==void 0||(f[k]=l.length/2,l.push(V.x,V.y)),f[k]}return e.data={},e.data.vertices=i,e.data.normals=o,c.length>0&&(e.data.colors=c),l.length>0&&(e.data.uvs=[l]),e.data.faces=s,e},clone:function(){return new de().copy(this)},copy:function(e){var t,r,i,n,a,s;this.vertices=[],this.colors=[],this.faces=[],this.faceVertexUvs=[[]],this.morphTargets=[],this.morphNormals=[],this.skinWeights=[],this.skinIndices=[],this.lineDistances=[],this.boundingBox=null,this.boundingSphere=null,this.name=e.name;var o=e.vertices;for(t=0,r=o.length;t<r;t++)this.vertices.push(o[t].clone());var h=e.colors;for(t=0,r=h.length;t<r;t++)this.colors.push(h[t].clone());var c=e.faces;for(t=0,r=c.length;t<r;t++)this.faces.push(c[t].clone());for(t=0,r=e.faceVertexUvs.length;t<r;t++){var u=e.faceVertexUvs[t];for(this.faceVertexUvs[t]===void 0&&(this.faceVertexUvs[t]=[]),i=0,n=u.length;i<n;i++){var l=u[i],f=[];for(a=0,s=l.length;a<s;a++){var d=l[a];f.push(d.clone())}this.faceVertexUvs[t].push(f)}}var p=e.morphTargets;for(t=0,r=p.length;t<r;t++){var m={};if(m.name=p[t].name,p[t].vertices!==void 0)for(m.vertices=[],i=0,n=p[t].vertices.length;i<n;i++)m.vertices.push(p[t].vertices[i].clone());if(p[t].normals!==void 0)for(m.normals=[],i=0,n=p[t].normals.length;i<n;i++)m.normals.push(p[t].normals[i].clone());this.morphTargets.push(m)}var v=e.morphNormals;for(t=0,r=v.length;t<r;t++){var g={};if(v[t].vertexNormals!==void 0)for(g.vertexNormals=[],i=0,n=v[t].vertexNormals.length;i<n;i++){var _=v[t].vertexNormals[i],w={};w.a=_.a.clone(),w.b=_.b.clone(),w.c=_.c.clone(),g.vertexNormals.push(w)}if(v[t].faceNormals!==void 0)for(g.faceNormals=[],i=0,n=v[t].faceNormals.length;i<n;i++)g.faceNormals.push(v[t].faceNormals[i].clone());this.morphNormals.push(g)}var y=e.skinWeights;for(t=0,r=y.length;t<r;t++)this.skinWeights.push(y[t].clone());var S=e.skinIndices;for(t=0,r=S.length;t<r;t++)this.skinIndices.push(S[t].clone());var R=e.lineDistances;for(t=0,r=R.length;t<r;t++)this.lineDistances.push(R[t]);var I=e.boundingBox;I!==null&&(this.boundingBox=I.clone());var C=e.boundingSphere;return C!==null&&(this.boundingSphere=C.clone()),this.elementsNeedUpdate=e.elementsNeedUpdate,this.verticesNeedUpdate=e.verticesNeedUpdate,this.uvsNeedUpdate=e.uvsNeedUpdate,this.normalsNeedUpdate=e.normalsNeedUpdate,this.colorsNeedUpdate=e.colorsNeedUpdate,this.lineDistancesNeedUpdate=e.lineDistancesNeedUpdate,this.groupsNeedUpdate=e.groupsNeedUpdate,this},dispose:function(){this.dispatchEvent({type:"dispose"})}});function xe(e,t,r){if(Array.isArray(e))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.name="",this.array=e,this.itemSize=t,this.count=e!==void 0?e.length/t:0,this.normalized=r===!0,this.dynamic=!1,this.updateRange={offset:0,count:-1},this.version=0}Object.defineProperty(xe.prototype,"needsUpdate",{set:function(e){e===!0&&this.version++}});Object.assign(xe.prototype,{isBufferAttribute:!0,onUploadCallback:function(){},setArray:function(e){if(Array.isArray(e))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");return this.count=e!==void 0?e.length/this.itemSize:0,this.array=e,this},setDynamic:function(e){return this.dynamic=e,this},copy:function(e){return this.name=e.name,this.array=new e.array.constructor(e.array),this.itemSize=e.itemSize,this.count=e.count,this.normalized=e.normalized,this.dynamic=e.dynamic,this},copyAt:function(e,t,r){e*=this.itemSize,r*=t.itemSize;for(var i=0,n=this.itemSize;i<n;i++)this.array[e+i]=t.array[r+i];return this},copyArray:function(e){return this.array.set(e),this},copyColorsArray:function(e){for(var t=this.array,r=0,i=0,n=e.length;i<n;i++){var a=e[i];a===void 0&&(console.warn("THREE.BufferAttribute.copyColorsArray(): color is undefined",i),a=new oe),t[r++]=a.r,t[r++]=a.g,t[r++]=a.b}return this},copyVector2sArray:function(e){for(var t=this.array,r=0,i=0,n=e.length;i<n;i++){var a=e[i];a===void 0&&(console.warn("THREE.BufferAttribute.copyVector2sArray(): vector is undefined",i),a=new z),t[r++]=a.x,t[r++]=a.y}return this},copyVector3sArray:function(e){for(var t=this.array,r=0,i=0,n=e.length;i<n;i++){var a=e[i];a===void 0&&(console.warn("THREE.BufferAttribute.copyVector3sArray(): vector is undefined",i),a=new b),t[r++]=a.x,t[r++]=a.y,t[r++]=a.z}return this},copyVector4sArray:function(e){for(var t=this.array,r=0,i=0,n=e.length;i<n;i++){var a=e[i];a===void 0&&(console.warn("THREE.BufferAttribute.copyVector4sArray(): vector is undefined",i),a=new Fe),t[r++]=a.x,t[r++]=a.y,t[r++]=a.z,t[r++]=a.w}return this},set:function(e,t){return t===void 0&&(t=0),this.array.set(e,t),this},getX:function(e){return this.array[e*this.itemSize]},setX:function(e,t){return this.array[e*this.itemSize]=t,this},getY:function(e){return this.array[e*this.itemSize+1]},setY:function(e,t){return this.array[e*this.itemSize+1]=t,this},getZ:function(e){return this.array[e*this.itemSize+2]},setZ:function(e,t){return this.array[e*this.itemSize+2]=t,this},getW:function(e){return this.array[e*this.itemSize+3]},setW:function(e,t){return this.array[e*this.itemSize+3]=t,this},setXY:function(e,t,r){return e*=this.itemSize,this.array[e+0]=t,this.array[e+1]=r,this},setXYZ:function(e,t,r,i){return e*=this.itemSize,this.array[e+0]=t,this.array[e+1]=r,this.array[e+2]=i,this},setXYZW:function(e,t,r,i,n){return e*=this.itemSize,this.array[e+0]=t,this.array[e+1]=r,this.array[e+2]=i,this.array[e+3]=n,this},onUpload:function(e){return this.onUploadCallback=e,this},clone:function(){return new this.constructor(this.array,this.itemSize).copy(this)}});function fa(e,t,r){xe.call(this,new Int8Array(e),t,r)}fa.prototype=Object.create(xe.prototype);fa.prototype.constructor=fa;function da(e,t,r){xe.call(this,new Uint8Array(e),t,r)}da.prototype=Object.create(xe.prototype);da.prototype.constructor=da;function pa(e,t,r){xe.call(this,new Uint8ClampedArray(e),t,r)}pa.prototype=Object.create(xe.prototype);pa.prototype.constructor=pa;function ma(e,t,r){xe.call(this,new Int16Array(e),t,r)}ma.prototype=Object.create(xe.prototype);ma.prototype.constructor=ma;function ii(e,t,r){xe.call(this,new Uint16Array(e),t,r)}ii.prototype=Object.create(xe.prototype);ii.prototype.constructor=ii;function va(e,t,r){xe.call(this,new Int32Array(e),t,r)}va.prototype=Object.create(xe.prototype);va.prototype.constructor=va;function ni(e,t,r){xe.call(this,new Uint32Array(e),t,r)}ni.prototype=Object.create(xe.prototype);ni.prototype.constructor=ni;function Z(e,t,r){xe.call(this,new Float32Array(e),t,r)}Z.prototype=Object.create(xe.prototype);Z.prototype.constructor=Z;function ga(e,t,r){xe.call(this,new Float64Array(e),t,r)}ga.prototype=Object.create(xe.prototype);ga.prototype.constructor=ga;function so(){this.vertices=[],this.normals=[],this.colors=[],this.uvs=[],this.uvs2=[],this.groups=[],this.morphTargets={},this.skinWeights=[],this.skinIndices=[],this.boundingBox=null,this.boundingSphere=null,this.verticesNeedUpdate=!1,this.normalsNeedUpdate=!1,this.colorsNeedUpdate=!1,this.uvsNeedUpdate=!1,this.groupsNeedUpdate=!1}Object.assign(so.prototype,{computeGroups:function(e){for(var t,r=[],i=void 0,n=e.faces,a=0;a<n.length;a++){var s=n[a];s.materialIndex!==i&&(i=s.materialIndex,t!==void 0&&(t.count=a*3-t.start,r.push(t)),t={start:a*3,materialIndex:i})}t!==void 0&&(t.count=a*3-t.start,r.push(t)),this.groups=r},fromGeometry:function(e){var t=e.faces,r=e.vertices,i=e.faceVertexUvs,n=i[0]&&i[0].length>0,a=i[1]&&i[1].length>0,s=e.morphTargets,o=s.length,h;if(o>0){h=[];for(var c=0;c<o;c++)h[c]={name:s[c].name,data:[]};this.morphTargets.position=h}var u=e.morphNormals,l=u.length,f;if(l>0){f=[];for(var c=0;c<l;c++)f[c]={name:u[c].name,data:[]};this.morphTargets.normal=f}var d=e.skinIndices,p=e.skinWeights,m=d.length===r.length,v=p.length===r.length;r.length>0&&t.length===0&&console.error("THREE.DirectGeometry: Faceless geometries are not supported.");for(var c=0;c<t.length;c++){var g=t[c];this.vertices.push(r[g.a],r[g.b],r[g.c]);var _=g.vertexNormals;if(_.length===3)this.normals.push(_[0],_[1],_[2]);else{var w=g.normal;this.normals.push(w,w,w)}var y=g.vertexColors;if(y.length===3)this.colors.push(y[0],y[1],y[2]);else{var S=g.color;this.colors.push(S,S,S)}if(n===!0){var R=i[0][c];R!==void 0?this.uvs.push(R[0],R[1],R[2]):(console.warn("THREE.DirectGeometry.fromGeometry(): Undefined vertexUv ",c),this.uvs.push(new z,new z,new z))}if(a===!0){var R=i[1][c];R!==void 0?this.uvs2.push(R[0],R[1],R[2]):(console.warn("THREE.DirectGeometry.fromGeometry(): Undefined vertexUv2 ",c),this.uvs2.push(new z,new z,new z))}for(var I=0;I<o;I++){var C=s[I].vertices;h[I].data.push(C[g.a],C[g.b],C[g.c])}for(var I=0;I<l;I++){var A=u[I].vertexNormals[c];f[I].data.push(A.a,A.b,A.c)}m&&this.skinIndices.push(d[g.a],d[g.b],d[g.c]),v&&this.skinWeights.push(p[g.a],p[g.b],p[g.c])}return this.computeGroups(e),this.verticesNeedUpdate=e.verticesNeedUpdate,this.normalsNeedUpdate=e.normalsNeedUpdate,this.colorsNeedUpdate=e.colorsNeedUpdate,this.uvsNeedUpdate=e.uvsNeedUpdate,this.groupsNeedUpdate=e.groupsNeedUpdate,this}});function oo(e){if(e.length===0)return-1/0;for(var t=e[0],r=1,i=e.length;r<i;++r)e[r]>t&&(t=e[r]);return t}var Al=1;function $(){Object.defineProperty(this,"id",{value:Al+=2}),this.uuid=ge.generateUUID(),this.name="",this.type="BufferGeometry",this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}$.prototype=Object.assign(Object.create(ar.prototype),{constructor:$,isBufferGeometry:!0,getIndex:function(){return this.index},setIndex:function(e){Array.isArray(e)?this.index=new(oo(e)>65535?ni:ii)(e,1):this.index=e},addAttribute:function(e,t){return!(t&&t.isBufferAttribute)&&!(t&&t.isInterleavedBufferAttribute)?(console.warn("THREE.BufferGeometry: .addAttribute() now expects ( name, attribute )."),this.addAttribute(e,new xe(arguments[1],arguments[2]))):e==="index"?(console.warn("THREE.BufferGeometry.addAttribute: Use .setIndex() for index attribute."),this.setIndex(t),this):(this.attributes[e]=t,this)},getAttribute:function(e){return this.attributes[e]},removeAttribute:function(e){return delete this.attributes[e],this},addGroup:function(e,t,r){this.groups.push({start:e,count:t,materialIndex:r!==void 0?r:0})},clearGroups:function(){this.groups=[]},setDrawRange:function(e,t){this.drawRange.start=e,this.drawRange.count=t},applyMatrix:function(e){var t=this.attributes.position;t!==void 0&&(e.applyToBufferAttribute(t),t.needsUpdate=!0);var r=this.attributes.normal;if(r!==void 0){var i=new nt().getNormalMatrix(e);i.applyToBufferAttribute(r),r.needsUpdate=!0}return this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this},rotateX:function(){var e=new fe;return function(r){return e.makeRotationX(r),this.applyMatrix(e),this}}(),rotateY:function(){var e=new fe;return function(r){return e.makeRotationY(r),this.applyMatrix(e),this}}(),rotateZ:function(){var e=new fe;return function(r){return e.makeRotationZ(r),this.applyMatrix(e),this}}(),translate:function(){var e=new fe;return function(r,i,n){return e.makeTranslation(r,i,n),this.applyMatrix(e),this}}(),scale:function(){var e=new fe;return function(r,i,n){return e.makeScale(r,i,n),this.applyMatrix(e),this}}(),lookAt:function(){var e=new K;return function(r){e.lookAt(r),e.updateMatrix(),this.applyMatrix(e.matrix)}}(),center:function(){var e=new b;return function(){return this.computeBoundingBox(),this.boundingBox.getCenter(e).negate(),this.translate(e.x,e.y,e.z),this}}(),setFromObject:function(e){var t=e.geometry;if(e.isPoints||e.isLine){var r=new Z(t.vertices.length*3,3),i=new Z(t.colors.length*3,3);if(this.addAttribute("position",r.copyVector3sArray(t.vertices)),this.addAttribute("color",i.copyColorsArray(t.colors)),t.lineDistances&&t.lineDistances.length===t.vertices.length){var n=new Z(t.lineDistances.length,1);this.addAttribute("lineDistance",n.copyArray(t.lineDistances))}t.boundingSphere!==null&&(this.boundingSphere=t.boundingSphere.clone()),t.boundingBox!==null&&(this.boundingBox=t.boundingBox.clone())}else e.isMesh&&t&&t.isGeometry&&this.fromGeometry(t);return this},setFromPoints:function(e){for(var t=[],r=0,i=e.length;r<i;r++){var n=e[r];t.push(n.x,n.y,n.z||0)}return this.addAttribute("position",new Z(t,3)),this},updateFromObject:function(e){var t=e.geometry;if(e.isMesh){var r=t.__directGeometry;if(t.elementsNeedUpdate===!0&&(r=void 0,t.elementsNeedUpdate=!1),r===void 0)return this.fromGeometry(t);r.verticesNeedUpdate=t.verticesNeedUpdate,r.normalsNeedUpdate=t.normalsNeedUpdate,r.colorsNeedUpdate=t.colorsNeedUpdate,r.uvsNeedUpdate=t.uvsNeedUpdate,r.groupsNeedUpdate=t.groupsNeedUpdate,t.verticesNeedUpdate=!1,t.normalsNeedUpdate=!1,t.colorsNeedUpdate=!1,t.uvsNeedUpdate=!1,t.groupsNeedUpdate=!1,t=r}var i;return t.verticesNeedUpdate===!0&&(i=this.attributes.position,i!==void 0&&(i.copyVector3sArray(t.vertices),i.needsUpdate=!0),t.verticesNeedUpdate=!1),t.normalsNeedUpdate===!0&&(i=this.attributes.normal,i!==void 0&&(i.copyVector3sArray(t.normals),i.needsUpdate=!0),t.normalsNeedUpdate=!1),t.colorsNeedUpdate===!0&&(i=this.attributes.color,i!==void 0&&(i.copyColorsArray(t.colors),i.needsUpdate=!0),t.colorsNeedUpdate=!1),t.uvsNeedUpdate&&(i=this.attributes.uv,i!==void 0&&(i.copyVector2sArray(t.uvs),i.needsUpdate=!0),t.uvsNeedUpdate=!1),t.lineDistancesNeedUpdate&&(i=this.attributes.lineDistance,i!==void 0&&(i.copyArray(t.lineDistances),i.needsUpdate=!0),t.lineDistancesNeedUpdate=!1),t.groupsNeedUpdate&&(t.computeGroups(e.geometry),this.groups=t.groups,t.groupsNeedUpdate=!1),this},fromGeometry:function(e){return e.__directGeometry=new so().fromGeometry(e),this.fromDirectGeometry(e.__directGeometry)},fromDirectGeometry:function(e){var t=new Float32Array(e.vertices.length*3);if(this.addAttribute("position",new xe(t,3).copyVector3sArray(e.vertices)),e.normals.length>0){var r=new Float32Array(e.normals.length*3);this.addAttribute("normal",new xe(r,3).copyVector3sArray(e.normals))}if(e.colors.length>0){var i=new Float32Array(e.colors.length*3);this.addAttribute("color",new xe(i,3).copyColorsArray(e.colors))}if(e.uvs.length>0){var n=new Float32Array(e.uvs.length*2);this.addAttribute("uv",new xe(n,2).copyVector2sArray(e.uvs))}if(e.uvs2.length>0){var a=new Float32Array(e.uvs2.length*2);this.addAttribute("uv2",new xe(a,2).copyVector2sArray(e.uvs2))}this.groups=e.groups;for(var s in e.morphTargets){for(var o=[],h=e.morphTargets[s],c=0,u=h.length;c<u;c++){var l=h[c],f=new Z(l.data.length*3,3);f.name=l.name,o.push(f.copyVector3sArray(l.data))}this.morphAttributes[s]=o}if(e.skinIndices.length>0){var d=new Z(e.skinIndices.length*4,4);this.addAttribute("skinIndex",d.copyVector4sArray(e.skinIndices))}if(e.skinWeights.length>0){var p=new Z(e.skinWeights.length*4,4);this.addAttribute("skinWeight",p.copyVector4sArray(e.skinWeights))}return e.boundingSphere!==null&&(this.boundingSphere=e.boundingSphere.clone()),e.boundingBox!==null&&(this.boundingBox=e.boundingBox.clone()),this},computeBoundingBox:function(){this.boundingBox===null&&(this.boundingBox=new tr);var e=this.attributes.position;e!==void 0?this.boundingBox.setFromBufferAttribute(e):this.boundingBox.makeEmpty(),(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox: Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)},computeBoundingSphere:function(){var e=new tr,t=new b;return function(){this.boundingSphere===null&&(this.boundingSphere=new Ot);var i=this.attributes.position;if(i){var n=this.boundingSphere.center;e.setFromBufferAttribute(i),e.getCenter(n);for(var a=0,s=0,o=i.count;s<o;s++)t.x=i.getX(s),t.y=i.getY(s),t.z=i.getZ(s),a=Math.max(a,n.distanceToSquared(t));this.boundingSphere.radius=Math.sqrt(a),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}}(),computeFaceNormals:function(){},computeVertexNormals:function(){var e=this.index,t=this.attributes;if(t.position){var r=t.position.array;if(t.normal===void 0)this.addAttribute("normal",new xe(new Float32Array(r.length),3));else for(var i=t.normal.array,n=0,a=i.length;n<a;n++)i[n]=0;var s=t.normal.array,o,h,c,u=new b,l=new b,f=new b,d=new b,p=new b;if(e)for(var m=e.array,n=0,a=e.count;n<a;n+=3)o=m[n+0]*3,h=m[n+1]*3,c=m[n+2]*3,u.fromArray(r,o),l.fromArray(r,h),f.fromArray(r,c),d.subVectors(f,l),p.subVectors(u,l),d.cross(p),s[o]+=d.x,s[o+1]+=d.y,s[o+2]+=d.z,s[h]+=d.x,s[h+1]+=d.y,s[h+2]+=d.z,s[c]+=d.x,s[c+1]+=d.y,s[c+2]+=d.z;else for(var n=0,a=r.length;n<a;n+=9)u.fromArray(r,n),l.fromArray(r,n+3),f.fromArray(r,n+6),d.subVectors(f,l),p.subVectors(u,l),d.cross(p),s[n]=d.x,s[n+1]=d.y,s[n+2]=d.z,s[n+3]=d.x,s[n+4]=d.y,s[n+5]=d.z,s[n+6]=d.x,s[n+7]=d.y,s[n+8]=d.z;this.normalizeNormals(),t.normal.needsUpdate=!0}},merge:function(e,t){if(!(e&&e.isBufferGeometry)){console.error("THREE.BufferGeometry.merge(): geometry not an instance of THREE.BufferGeometry.",e);return}t===void 0&&(t=0,console.warn("THREE.BufferGeometry.merge(): Overwriting original geometry, starting at offset=0. Use BufferGeometryUtils.mergeBufferGeometries() for lossless merge."));var r=this.attributes;for(var i in r)if(e.attributes[i]!==void 0)for(var n=r[i],a=n.array,s=e.attributes[i],o=s.array,h=s.itemSize,c=0,u=h*t;c<o.length;c++,u++)a[u]=o[c];return this},normalizeNormals:function(){var e=new b;return function(){for(var r=this.attributes.normal,i=0,n=r.count;i<n;i++)e.x=r.getX(i),e.y=r.getY(i),e.z=r.getZ(i),e.normalize(),r.setXYZ(i,e.x,e.y,e.z)}}(),toNonIndexed:function(){function e(m,v){for(var g=m.array,_=m.itemSize,w=new g.constructor(v.length*_),y=0,S=0,R=0,I=v.length;R<I;R++){y=v[R]*_;for(var C=0;C<_;C++)w[S++]=g[y++]}return new xe(w,_)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): Geometry is already non-indexed."),this;var t=new $,r=this.index.array,i=this.attributes;for(var n in i){var a=i[n],s=e(a,r);t.addAttribute(n,s)}var o=this.morphAttributes;for(n in o){for(var h=[],c=o[n],u=0,l=c.length;u<l;u++){var a=c[u],s=e(a,r);h.push(s)}t.morphAttributes[n]=h}for(var f=this.groups,u=0,d=f.length;u<d;u++){var p=f[u];t.addGroup(p.start,p.count,p.materialIndex)}return t},toJSON:function(){var e={metadata:{version:4.5,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(e.uuid=this.uuid,e.type=this.type,this.name!==""&&(e.name=this.name),Object.keys(this.userData).length>0&&(e.userData=this.userData),this.parameters!==void 0){var t=this.parameters;for(var r in t)t[r]!==void 0&&(e[r]=t[r]);return e}e.data={attributes:{}};var i=this.index;if(i!==null){var n=Array.prototype.slice.call(i.array);e.data.index={type:i.array.constructor.name,array:n}}var a=this.attributes;for(var r in a){var s=a[r],n=Array.prototype.slice.call(s.array);e.data.attributes[r]={itemSize:s.itemSize,type:s.array.constructor.name,array:n,normalized:s.normalized}}var o=this.groups;o.length>0&&(e.data.groups=JSON.parse(JSON.stringify(o)));var h=this.boundingSphere;return h!==null&&(e.data.boundingSphere={center:h.center.toArray(),radius:h.radius}),e},clone:function(){return new $().copy(this)},copy:function(e){var t,r,i;this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.name=e.name;var n=e.index;n!==null&&this.setIndex(n.clone());var a=e.attributes;for(t in a){var s=a[t];this.addAttribute(t,s.clone())}var o=e.morphAttributes;for(t in o){var h=[],c=o[t];for(r=0,i=c.length;r<i;r++)h.push(c[r].clone());this.morphAttributes[t]=h}var u=e.groups;for(r=0,i=u.length;r<i;r++){var l=u[r];this.addGroup(l.start,l.count,l.materialIndex)}var f=e.boundingBox;f!==null&&(this.boundingBox=f.clone());var d=e.boundingSphere;return d!==null&&(this.boundingSphere=d.clone()),this.drawRange.start=e.drawRange.start,this.drawRange.count=e.drawRange.count,this.userData=e.userData,this},dispose:function(){this.dispatchEvent({type:"dispose"})}});function tn(e,t,r,i,n,a){de.call(this),this.type="BoxGeometry",this.parameters={width:e,height:t,depth:r,widthSegments:i,heightSegments:n,depthSegments:a},this.fromBufferGeometry(new Ar(e,t,r,i,n,a)),this.mergeVertices()}tn.prototype=Object.create(de.prototype);tn.prototype.constructor=tn;function Ar(e,t,r,i,n,a){$.call(this),this.type="BoxBufferGeometry",this.parameters={width:e,height:t,depth:r,widthSegments:i,heightSegments:n,depthSegments:a};var s=this;e=e||1,t=t||1,r=r||1,i=Math.floor(i)||1,n=Math.floor(n)||1,a=Math.floor(a)||1;var o=[],h=[],c=[],u=[],l=0,f=0;d("z","y","x",-1,-1,r,t,e,a,n,0),d("z","y","x",1,-1,r,t,-e,a,n,1),d("x","z","y",1,1,e,r,t,i,a,2),d("x","z","y",1,-1,e,r,-t,i,a,3),d("x","y","z",1,-1,e,t,r,i,n,4),d("x","y","z",-1,-1,e,t,-r,i,n,5),this.setIndex(o),this.addAttribute("position",new Z(h,3)),this.addAttribute("normal",new Z(c,3)),this.addAttribute("uv",new Z(u,2));function d(p,m,v,g,_,w,y,S,R,I,C){var A=w/R,O=y/I,F=w/2,N=y/2,V=S/2,k=R+1,G=I+1,J=0,Y=0,q,E,T=new b;for(E=0;E<G;E++){var U=E*O-N;for(q=0;q<k;q++){var L=q*A-F;T[p]=L*g,T[m]=U*_,T[v]=V,h.push(T.x,T.y,T.z),T[p]=0,T[m]=0,T[v]=S>0?1:-1,c.push(T.x,T.y,T.z),u.push(q/R),u.push(1-E/I),J+=1}}for(E=0;E<I;E++)for(q=0;q<R;q++){var Q=l+q+k*E,B=l+q+k*(E+1),W=l+(q+1)+k*(E+1),j=l+(q+1)+k*E;o.push(Q,B,j),o.push(B,W,j),Y+=6}s.addGroup(f,Y,C),f+=Y,l+=J}}Ar.prototype=Object.create($.prototype);Ar.prototype.constructor=Ar;function rn(e,t,r,i){de.call(this),this.type="PlaneGeometry",this.parameters={width:e,height:t,widthSegments:r,heightSegments:i},this.fromBufferGeometry(new lr(e,t,r,i)),this.mergeVertices()}rn.prototype=Object.create(de.prototype);rn.prototype.constructor=rn;function lr(e,t,r,i){$.call(this),this.type="PlaneBufferGeometry",this.parameters={width:e,height:t,widthSegments:r,heightSegments:i},e=e||1,t=t||1;var n=e/2,a=t/2,s=Math.floor(r)||1,o=Math.floor(i)||1,h=s+1,c=o+1,u=e/s,l=t/o,f,d,p=[],m=[],v=[],g=[];for(d=0;d<c;d++){var _=d*l-a;for(f=0;f<h;f++){var w=f*u-n;m.push(w,-_,0),v.push(0,0,1),g.push(f/s),g.push(1-d/o)}}for(d=0;d<o;d++)for(f=0;f<s;f++){var y=f+h*d,S=f+h*(d+1),R=f+1+h*(d+1),I=f+1+h*d;p.push(y,S,I),p.push(S,R,I)}this.setIndex(p),this.addAttribute("position",new Z(m,3)),this.addAttribute("normal",new Z(v,3)),this.addAttribute("uv",new Z(g,2))}lr.prototype=Object.create($.prototype);lr.prototype.constructor=lr;var Ll=0;function ve(){Object.defineProperty(this,"id",{value:Ll++}),this.uuid=ge.generateUUID(),this.name="",this.type="Material",this.fog=!0,this.lights=!0,this.blending=br,this.side=Bi,this.flatShading=!1,this.vertexColors=qs,this.opacity=1,this.transparent=!1,this.blendSrc=Js,this.blendDst=Qs,this.blendEquation=_r,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.depthFunc=ca,this.depthTest=!0,this.depthWrite=!0,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaTest=0,this.premultipliedAlpha=!1,this.visible=!0,this.userData={},this.needsUpdate=!0}ve.prototype=Object.assign(Object.create(ar.prototype),{constructor:ve,isMaterial:!0,onBeforeCompile:function(){},setValues:function(e){if(e!==void 0)for(var t in e){var r=e[t];if(r===void 0){console.warn("THREE.Material: '"+t+"' parameter is undefined.");continue}if(t==="shading"){console.warn("THREE."+this.type+": .shading has been removed. Use the boolean .flatShading instead."),this.flatShading=r===js;continue}var i=this[t];if(i===void 0){console.warn("THREE."+this.type+": '"+t+"' is not a property of this material.");continue}i&&i.isColor?i.set(r):i&&i.isVector3&&r&&r.isVector3?i.copy(r):this[t]=r}},toJSON:function(e){var t=e===void 0||typeof e=="string";t&&(e={textures:{},images:{}});var r={metadata:{version:4.5,type:"Material",generator:"Material.toJSON"}};r.uuid=this.uuid,r.type=this.type,this.name!==""&&(r.name=this.name),this.color&&this.color.isColor&&(r.color=this.color.getHex()),this.roughness!==void 0&&(r.roughness=this.roughness),this.metalness!==void 0&&(r.metalness=this.metalness),this.emissive&&this.emissive.isColor&&(r.emissive=this.emissive.getHex()),this.emissiveIntensity!==1&&(r.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(r.specular=this.specular.getHex()),this.shininess!==void 0&&(r.shininess=this.shininess),this.clearCoat!==void 0&&(r.clearCoat=this.clearCoat),this.clearCoatRoughness!==void 0&&(r.clearCoatRoughness=this.clearCoatRoughness),this.map&&this.map.isTexture&&(r.map=this.map.toJSON(e).uuid),this.alphaMap&&this.alphaMap.isTexture&&(r.alphaMap=this.alphaMap.toJSON(e).uuid),this.lightMap&&this.lightMap.isTexture&&(r.lightMap=this.lightMap.toJSON(e).uuid),this.aoMap&&this.aoMap.isTexture&&(r.aoMap=this.aoMap.toJSON(e).uuid,r.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(r.bumpMap=this.bumpMap.toJSON(e).uuid,r.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(r.normalMap=this.normalMap.toJSON(e).uuid,r.normalMapType=this.normalMapType,r.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(r.displacementMap=this.displacementMap.toJSON(e).uuid,r.displacementScale=this.displacementScale,r.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(r.roughnessMap=this.roughnessMap.toJSON(e).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(r.metalnessMap=this.metalnessMap.toJSON(e).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(r.emissiveMap=this.emissiveMap.toJSON(e).uuid),this.specularMap&&this.specularMap.isTexture&&(r.specularMap=this.specularMap.toJSON(e).uuid),this.envMap&&this.envMap.isTexture&&(r.envMap=this.envMap.toJSON(e).uuid,r.reflectivity=this.reflectivity,this.combine!==void 0&&(r.combine=this.combine),this.envMapIntensity!==void 0&&(r.envMapIntensity=this.envMapIntensity)),this.gradientMap&&this.gradientMap.isTexture&&(r.gradientMap=this.gradientMap.toJSON(e).uuid),this.size!==void 0&&(r.size=this.size),this.sizeAttenuation!==void 0&&(r.sizeAttenuation=this.sizeAttenuation),this.blending!==br&&(r.blending=this.blending),this.flatShading===!0&&(r.flatShading=this.flatShading),this.side!==Bi&&(r.side=this.side),this.vertexColors!==qs&&(r.vertexColors=this.vertexColors),this.opacity<1&&(r.opacity=this.opacity),this.transparent===!0&&(r.transparent=this.transparent),r.depthFunc=this.depthFunc,r.depthTest=this.depthTest,r.depthWrite=this.depthWrite,this.rotation!==0&&(r.rotation=this.rotation),this.polygonOffset===!0&&(r.polygonOffset=!0),this.polygonOffsetFactor!==0&&(r.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(r.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==1&&(r.linewidth=this.linewidth),this.dashSize!==void 0&&(r.dashSize=this.dashSize),this.gapSize!==void 0&&(r.gapSize=this.gapSize),this.scale!==void 0&&(r.scale=this.scale),this.dithering===!0&&(r.dithering=!0),this.alphaTest>0&&(r.alphaTest=this.alphaTest),this.premultipliedAlpha===!0&&(r.premultipliedAlpha=this.premultipliedAlpha),this.wireframe===!0&&(r.wireframe=this.wireframe),this.wireframeLinewidth>1&&(r.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(r.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(r.wireframeLinejoin=this.wireframeLinejoin),this.morphTargets===!0&&(r.morphTargets=!0),this.skinning===!0&&(r.skinning=!0),this.visible===!1&&(r.visible=!1),JSON.stringify(this.userData)!=="{}"&&(r.userData=this.userData);function i(s){var o=[];for(var h in s){var c=s[h];delete c.metadata,o.push(c)}return o}if(t){var n=i(e.textures),a=i(e.images);n.length>0&&(r.textures=n),a.length>0&&(r.images=a)}return r},clone:function(){return new this.constructor().copy(this)},copy:function(e){this.name=e.name,this.fog=e.fog,this.lights=e.lights,this.blending=e.blending,this.side=e.side,this.flatShading=e.flatShading,this.vertexColors=e.vertexColors,this.opacity=e.opacity,this.transparent=e.transparent,this.blendSrc=e.blendSrc,this.blendDst=e.blendDst,this.blendEquation=e.blendEquation,this.blendSrcAlpha=e.blendSrcAlpha,this.blendDstAlpha=e.blendDstAlpha,this.blendEquationAlpha=e.blendEquationAlpha,this.depthFunc=e.depthFunc,this.depthTest=e.depthTest,this.depthWrite=e.depthWrite,this.colorWrite=e.colorWrite,this.precision=e.precision,this.polygonOffset=e.polygonOffset,this.polygonOffsetFactor=e.polygonOffsetFactor,this.polygonOffsetUnits=e.polygonOffsetUnits,this.dithering=e.dithering,this.alphaTest=e.alphaTest,this.premultipliedAlpha=e.premultipliedAlpha,this.visible=e.visible,this.userData=JSON.parse(JSON.stringify(e.userData)),this.clipShadows=e.clipShadows,this.clipIntersection=e.clipIntersection;var t=e.clippingPlanes,r=null;if(t!==null){var i=t.length;r=new Array(i);for(var n=0;n!==i;++n)r[n]=t[n].clone()}return this.clippingPlanes=r,this.shadowSide=e.shadowSide,this},dispose:function(){this.dispatchEvent({type:"dispose"})}});function xt(e){ve.call(this),this.type="ShaderMaterial",this.defines={},this.uniforms={},this.vertexShader=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,this.fragmentShader=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.extensions={derivatives:!1,fragDepth:!1,drawBuffers:!1,shaderTextureLOD:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv2:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,e!==void 0&&(e.attributes!==void 0&&console.error("THREE.ShaderMaterial: attributes should now be defined in THREE.BufferGeometry instead."),this.setValues(e))}xt.prototype=Object.create(ve.prototype);xt.prototype.constructor=xt;xt.prototype.isShaderMaterial=!0;xt.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.fragmentShader=e.fragmentShader,this.vertexShader=e.vertexShader,this.uniforms=ri(e.uniforms),this.defines=Object.assign({},e.defines),this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.lights=e.lights,this.clipping=e.clipping,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this.extensions=e.extensions,this};xt.prototype.toJSON=function(e){var t=ve.prototype.toJSON.call(this,e);t.uniforms={};for(var r in this.uniforms){var i=this.uniforms[r],n=i.value;n&&n.isTexture?t.uniforms[r]={type:"t",value:n.toJSON(e).uuid}:n&&n.isColor?t.uniforms[r]={type:"c",value:n.getHex()}:n&&n.isVector2?t.uniforms[r]={type:"v2",value:n.toArray()}:n&&n.isVector3?t.uniforms[r]={type:"v3",value:n.toArray()}:n&&n.isVector4?t.uniforms[r]={type:"v4",value:n.toArray()}:n&&n.isMatrix3?t.uniforms[r]={type:"m3",value:n.toArray()}:n&&n.isMatrix4?t.uniforms[r]={type:"m4",value:n.toArray()}:t.uniforms[r]={value:n}}Object.keys(this.defines).length>0&&(t.defines=this.defines),t.vertexShader=this.vertexShader,t.fragmentShader=this.fragmentShader;var a={};for(var s in this.extensions)this.extensions[s]===!0&&(a[s]=!0);return Object.keys(a).length>0&&(t.extensions=a),t};function jr(e,t){this.origin=e!==void 0?e:new b,this.direction=t!==void 0?t:new b}Object.assign(jr.prototype,{set:function(e,t){return this.origin.copy(e),this.direction.copy(t),this},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.origin.copy(e.origin),this.direction.copy(e.direction),this},at:function(e,t){return t===void 0&&(console.warn("THREE.Ray: .at() target is now required"),t=new b),t.copy(this.direction).multiplyScalar(e).add(this.origin)},lookAt:function(e){return this.direction.copy(e).sub(this.origin).normalize(),this},recast:function(){var e=new b;return function(r){return this.origin.copy(this.at(r,e)),this}}(),closestPointToPoint:function(e,t){t===void 0&&(console.warn("THREE.Ray: .closestPointToPoint() target is now required"),t=new b),t.subVectors(e,this.origin);var r=t.dot(this.direction);return r<0?t.copy(this.origin):t.copy(this.direction).multiplyScalar(r).add(this.origin)},distanceToPoint:function(e){return Math.sqrt(this.distanceSqToPoint(e))},distanceSqToPoint:function(){var e=new b;return function(r){var i=e.subVectors(r,this.origin).dot(this.direction);return i<0?this.origin.distanceToSquared(r):(e.copy(this.direction).multiplyScalar(i).add(this.origin),e.distanceToSquared(r))}}(),distanceSqToSegment:function(){var e=new b,t=new b,r=new b;return function(n,a,s,o){e.copy(n).add(a).multiplyScalar(.5),t.copy(a).sub(n).normalize(),r.copy(this.origin).sub(e);var h=n.distanceTo(a)*.5,c=-this.direction.dot(t),u=r.dot(this.direction),l=-r.dot(t),f=r.lengthSq(),d=Math.abs(1-c*c),p,m,v,g;if(d>0)if(p=c*l-u,m=c*u-l,g=h*d,p>=0)if(m>=-g)if(m<=g){var _=1/d;p*=_,m*=_,v=p*(p+c*m+2*u)+m*(c*p+m+2*l)+f}else m=h,p=Math.max(0,-(c*m+u)),v=-p*p+m*(m+2*l)+f;else m=-h,p=Math.max(0,-(c*m+u)),v=-p*p+m*(m+2*l)+f;else m<=-g?(p=Math.max(0,-(-c*h+u)),m=p>0?-h:Math.min(Math.max(-h,-l),h),v=-p*p+m*(m+2*l)+f):m<=g?(p=0,m=Math.min(Math.max(-h,-l),h),v=m*(m+2*l)+f):(p=Math.max(0,-(c*h+u)),m=p>0?h:Math.min(Math.max(-h,-l),h),v=-p*p+m*(m+2*l)+f);else m=c>0?-h:h,p=Math.max(0,-(c*m+u)),v=-p*p+m*(m+2*l)+f;return s&&s.copy(this.direction).multiplyScalar(p).add(this.origin),o&&o.copy(t).multiplyScalar(m).add(e),v}}(),intersectSphere:function(){var e=new b;return function(r,i){e.subVectors(r.center,this.origin);var n=e.dot(this.direction),a=e.dot(e)-n*n,s=r.radius*r.radius;if(a>s)return null;var o=Math.sqrt(s-a),h=n-o,c=n+o;return h<0&&c<0?null:h<0?this.at(c,i):this.at(h,i)}}(),intersectsSphere:function(e){return this.distanceSqToPoint(e.center)<=e.radius*e.radius},distanceToPlane:function(e){var t=e.normal.dot(this.direction);if(t===0)return e.distanceToPoint(this.origin)===0?0:null;var r=-(this.origin.dot(e.normal)+e.constant)/t;return r>=0?r:null},intersectPlane:function(e,t){var r=this.distanceToPlane(e);return r===null?null:this.at(r,t)},intersectsPlane:function(e){var t=e.distanceToPoint(this.origin);if(t===0)return!0;var r=e.normal.dot(this.direction);return r*t<0},intersectBox:function(e,t){var r,i,n,a,s,o,h=1/this.direction.x,c=1/this.direction.y,u=1/this.direction.z,l=this.origin;return h>=0?(r=(e.min.x-l.x)*h,i=(e.max.x-l.x)*h):(r=(e.max.x-l.x)*h,i=(e.min.x-l.x)*h),c>=0?(n=(e.min.y-l.y)*c,a=(e.max.y-l.y)*c):(n=(e.max.y-l.y)*c,a=(e.min.y-l.y)*c),r>a||n>i||((n>r||r!==r)&&(r=n),(a<i||i!==i)&&(i=a),u>=0?(s=(e.min.z-l.z)*u,o=(e.max.z-l.z)*u):(s=(e.max.z-l.z)*u,o=(e.min.z-l.z)*u),r>o||s>i)||((s>r||r!==r)&&(r=s),(o<i||i!==i)&&(i=o),i<0)?null:this.at(r>=0?r:i,t)},intersectsBox:function(){var e=new b;return function(r){return this.intersectBox(r,e)!==null}}(),intersectTriangle:function(){var e=new b,t=new b,r=new b,i=new b;return function(a,s,o,h,c){t.subVectors(s,a),r.subVectors(o,a),i.crossVectors(t,r);var u=this.direction.dot(i),l;if(u>0){if(h)return null;l=1}else if(u<0)l=-1,u=-u;else return null;e.subVectors(this.origin,a);var f=l*this.direction.dot(r.crossVectors(e,r));if(f<0)return null;var d=l*this.direction.dot(t.cross(e));if(d<0||f+d>u)return null;var p=-l*e.dot(i);return p<0?null:this.at(p/u,c)}}(),applyMatrix4:function(e){return this.origin.applyMatrix4(e),this.direction.transformDirection(e),this},equals:function(e){return e.origin.equals(this.origin)&&e.direction.equals(this.direction)}});function ot(e,t,r){this.a=e!==void 0?e:new b,this.b=t!==void 0?t:new b,this.c=r!==void 0?r:new b}Object.assign(ot,{getNormal:function(){var e=new b;return function(r,i,n,a){a===void 0&&(console.warn("THREE.Triangle: .getNormal() target is now required"),a=new b),a.subVectors(n,i),e.subVectors(r,i),a.cross(e);var s=a.lengthSq();return s>0?a.multiplyScalar(1/Math.sqrt(s)):a.set(0,0,0)}}(),getBarycoord:function(){var e=new b,t=new b,r=new b;return function(n,a,s,o,h){e.subVectors(o,a),t.subVectors(s,a),r.subVectors(n,a);var c=e.dot(e),u=e.dot(t),l=e.dot(r),f=t.dot(t),d=t.dot(r),p=c*f-u*u;if(h===void 0&&(console.warn("THREE.Triangle: .getBarycoord() target is now required"),h=new b),p===0)return h.set(-2,-1,-1);var m=1/p,v=(f*l-u*d)*m,g=(c*d-u*l)*m;return h.set(1-v-g,g,v)}}(),containsPoint:function(){var e=new b;return function(r,i,n,a){return ot.getBarycoord(r,i,n,a,e),e.x>=0&&e.y>=0&&e.x+e.y<=1}}(),getUV:function(){var e=new b;return function(r,i,n,a,s,o,h,c){return this.getBarycoord(r,i,n,a,e),c.set(0,0),c.addScaledVector(s,e.x),c.addScaledVector(o,e.y),c.addScaledVector(h,e.z),c}}()});Object.assign(ot.prototype,{set:function(e,t,r){return this.a.copy(e),this.b.copy(t),this.c.copy(r),this},setFromPointsAndIndices:function(e,t,r,i){return this.a.copy(e[t]),this.b.copy(e[r]),this.c.copy(e[i]),this},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.a.copy(e.a),this.b.copy(e.b),this.c.copy(e.c),this},getArea:function(){var e=new b,t=new b;return function(){return e.subVectors(this.c,this.b),t.subVectors(this.a,this.b),e.cross(t).length()*.5}}(),getMidpoint:function(e){return e===void 0&&(console.warn("THREE.Triangle: .getMidpoint() target is now required"),e=new b),e.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)},getNormal:function(e){return ot.getNormal(this.a,this.b,this.c,e)},getPlane:function(e){return e===void 0&&(console.warn("THREE.Triangle: .getPlane() target is now required"),e=new b),e.setFromCoplanarPoints(this.a,this.b,this.c)},getBarycoord:function(e,t){return ot.getBarycoord(e,this.a,this.b,this.c,t)},containsPoint:function(e){return ot.containsPoint(e,this.a,this.b,this.c)},getUV:function(e,t,r,i,n){return ot.getUV(e,this.a,this.b,this.c,t,r,i,n)},intersectsBox:function(e){return e.intersectsTriangle(this)},closestPointToPoint:function(){var e=new b,t=new b,r=new b,i=new b,n=new b,a=new b;return function(o,h){h===void 0&&(console.warn("THREE.Triangle: .closestPointToPoint() target is now required"),h=new b);var c=this.a,u=this.b,l=this.c,f,d;e.subVectors(u,c),t.subVectors(l,c),i.subVectors(o,c);var p=e.dot(i),m=t.dot(i);if(p<=0&&m<=0)return h.copy(c);n.subVectors(o,u);var v=e.dot(n),g=t.dot(n);if(v>=0&&g<=v)return h.copy(u);var _=p*g-v*m;if(_<=0&&p>=0&&v<=0)return f=p/(p-v),h.copy(c).addScaledVector(e,f);a.subVectors(o,l);var w=e.dot(a),y=t.dot(a);if(y>=0&&w<=y)return h.copy(l);var S=w*m-p*y;if(S<=0&&m>=0&&y<=0)return d=m/(m-y),h.copy(c).addScaledVector(t,d);var R=v*y-w*g;if(R<=0&&g-v>=0&&w-y>=0)return r.subVectors(l,u),d=(g-v)/(g-v+(w-y)),h.copy(u).addScaledVector(r,d);var I=1/(R+S+_);return f=S*I,d=_*I,h.copy(c).addScaledVector(e,f).addScaledVector(t,d)}}(),equals:function(e){return e.a.equals(this.a)&&e.b.equals(this.b)&&e.c.equals(this.c)}});function St(e){ve.call(this),this.type="MeshBasicMaterial",this.color=new oe(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=Hn,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.skinning=!1,this.morphTargets=!1,this.lights=!1,this.setValues(e)}St.prototype=Object.create(ve.prototype);St.prototype.constructor=St;St.prototype.isMeshBasicMaterial=!0;St.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.combine=e.combine,this.reflectivity=e.reflectivity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this};function lt(e,t){K.call(this),this.type="Mesh",this.geometry=e!==void 0?e:new $,this.material=t!==void 0?t:new St({color:Math.random()*16777215}),this.drawMode=io,this.updateMorphTargets()}lt.prototype=Object.assign(Object.create(K.prototype),{constructor:lt,isMesh:!0,setDrawMode:function(e){this.drawMode=e},copy:function(e){return K.prototype.copy.call(this,e),this.drawMode=e.drawMode,e.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=e.morphTargetInfluences.slice()),e.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},e.morphTargetDictionary)),this},updateMorphTargets:function(){var e=this.geometry,t,r,i;if(e.isBufferGeometry){var n=e.morphAttributes,a=Object.keys(n);if(a.length>0){var s=n[a[0]];if(s!==void 0)for(this.morphTargetInfluences=[],this.morphTargetDictionary={},t=0,r=s.length;t<r;t++)i=s[t].name||String(t),this.morphTargetInfluences.push(0),this.morphTargetDictionary[i]=t}}else{var o=e.morphTargets;o!==void 0&&o.length>0&&console.error("THREE.Mesh.updateMorphTargets() no longer supports THREE.Geometry. Use THREE.BufferGeometry instead.")}},raycast:function(){var e=new fe,t=new jr,r=new Ot,i=new b,n=new b,a=new b,s=new b,o=new b,h=new b,c=new z,u=new z,l=new z,f=new b,d=new b;function p(v,g,_,w,y,S,R,I){var C;if(g.side===st?C=w.intersectTriangle(R,S,y,!0,I):C=w.intersectTriangle(y,S,R,g.side!==Ni,I),C===null)return null;d.copy(I),d.applyMatrix4(v.matrixWorld);var A=_.ray.origin.distanceTo(d);return A<_.near||A>_.far?null:{distance:A,point:d.clone(),object:v}}function m(v,g,_,w,y,S,R,I,C){i.fromBufferAttribute(y,R),n.fromBufferAttribute(y,I),a.fromBufferAttribute(y,C);var A=p(v,g,_,w,i,n,a,f);if(A){S&&(c.fromBufferAttribute(S,R),u.fromBufferAttribute(S,I),l.fromBufferAttribute(S,C),A.uv=ot.getUV(f,i,n,a,c,u,l,new z));var O=new en(R,I,C);ot.getNormal(i,n,a,O.normal),A.face=O}return A}return function(g,_){var w=this.geometry,y=this.material,S=this.matrixWorld;if(y!==void 0&&(w.boundingSphere===null&&w.computeBoundingSphere(),r.copy(w.boundingSphere),r.applyMatrix4(S),g.ray.intersectsSphere(r)!==!1&&(e.getInverse(S),t.copy(g.ray).applyMatrix4(e),!(w.boundingBox!==null&&t.intersectsBox(w.boundingBox)===!1)))){var R;if(w.isBufferGeometry){var I,C,A,O=w.index,F=w.attributes.position,N=w.attributes.uv,V=w.groups,k=w.drawRange,G,J,Y,q,E,T,U,L;if(O!==null)if(Array.isArray(y))for(G=0,Y=V.length;G<Y;G++)for(E=V[G],T=y[E.materialIndex],U=Math.max(E.start,k.start),L=Math.min(E.start+E.count,k.start+k.count),J=U,q=L;J<q;J+=3)I=O.getX(J),C=O.getX(J+1),A=O.getX(J+2),R=m(this,T,g,t,F,N,I,C,A),R&&(R.faceIndex=Math.floor(J/3),_.push(R));else for(U=Math.max(0,k.start),L=Math.min(O.count,k.start+k.count),G=U,Y=L;G<Y;G+=3)I=O.getX(G),C=O.getX(G+1),A=O.getX(G+2),R=m(this,y,g,t,F,N,I,C,A),R&&(R.faceIndex=Math.floor(G/3),_.push(R));else if(F!==void 0)if(Array.isArray(y))for(G=0,Y=V.length;G<Y;G++)for(E=V[G],T=y[E.materialIndex],U=Math.max(E.start,k.start),L=Math.min(E.start+E.count,k.start+k.count),J=U,q=L;J<q;J+=3)I=J,C=J+1,A=J+2,R=m(this,T,g,t,F,N,I,C,A),R&&(R.faceIndex=Math.floor(J/3),_.push(R));else for(U=Math.max(0,k.start),L=Math.min(F.count,k.start+k.count),G=U,Y=L;G<Y;G+=3)I=G,C=G+1,A=G+2,R=m(this,y,g,t,F,N,I,C,A),R&&(R.faceIndex=Math.floor(G/3),_.push(R))}else if(w.isGeometry){var Q,B,W,j=Array.isArray(y),pe=w.vertices,me=w.faces,le,H=w.faceVertexUvs[0];H.length>0&&(le=H);for(var he=0,Re=me.length;he<Re;he++){var _e=me[he],rt=j?y[_e.materialIndex]:y;if(rt!==void 0){if(Q=pe[_e.a],B=pe[_e.b],W=pe[_e.c],rt.morphTargets===!0){var ze=w.morphTargets,Ye=this.morphTargetInfluences;i.set(0,0,0),n.set(0,0,0),a.set(0,0,0);for(var Ke=0,zt=ze.length;Ke<zt;Ke++){var Lt=Ye[Ke];if(Lt!==0){var We=ze[Ke].vertices;i.addScaledVector(s.subVectors(We[_e.a],Q),Lt),n.addScaledVector(o.subVectors(We[_e.b],B),Lt),a.addScaledVector(h.subVectors(We[_e.c],W),Lt)}}i.add(Q),n.add(B),a.add(W),Q=i,B=n,W=a}if(R=p(this,rt,g,t,Q,B,W,f),R){if(le&&le[he]){var Ze=le[he];c.copy(Ze[0]),u.copy(Ze[1]),l.copy(Ze[2]),R.uv=ot.getUV(f,Q,B,W,c,u,l,new z)}R.face=_e,R.faceIndex=he,_.push(R)}}}}}}}(),clone:function(){return new this.constructor(this.geometry,this.material).copy(this)}});function Rl(e,t,r,i){var n=new oe(0),a=0,s,o,h=null,c=0;function u(f,d,p,m){var v=d.background;if(v===null?(l(n,a),h=null,c=0):v&&v.isColor&&(l(v,1),m=!0,h=null,c=0),(e.autoClear||m)&&e.clear(e.autoClearColor,e.autoClearDepth,e.autoClearStencil),v&&(v.isCubeTexture||v.isWebGLRenderTargetCube)){o===void 0&&(o=new lt(new Ar(1,1,1),new xt({type:"BackgroundCubeMaterial",uniforms:ri(kt.cube.uniforms),vertexShader:kt.cube.vertexShader,fragmentShader:kt.cube.fragmentShader,side:st,depthTest:!0,depthWrite:!1,fog:!1})),o.geometry.removeAttribute("normal"),o.geometry.removeAttribute("uv"),o.onBeforeRender=function(_,w,y){this.matrixWorld.copyPosition(y.matrixWorld)},Object.defineProperty(o.material,"map",{get:function(){return this.uniforms.tCube.value}}),r.update(o));var g=v.isWebGLRenderTargetCube?v.texture:v;o.material.uniforms.tCube.value=g,o.material.uniforms.tFlip.value=v.isWebGLRenderTargetCube?1:-1,(h!==v||c!==g.version)&&(o.material.needsUpdate=!0,h=v,c=g.version),f.unshift(o,o.geometry,o.material,0,0,null)}else v&&v.isTexture&&(s===void 0&&(s=new lt(new lr(2,2),new xt({type:"BackgroundMaterial",uniforms:ri(kt.background.uniforms),vertexShader:kt.background.vertexShader,fragmentShader:kt.background.fragmentShader,side:Bi,depthTest:!1,depthWrite:!1,fog:!1})),s.geometry.removeAttribute("normal"),Object.defineProperty(s.material,"map",{get:function(){return this.uniforms.t2D.value}}),r.update(s)),s.material.uniforms.t2D.value=v,v.matrixAutoUpdate===!0&&v.updateMatrix(),s.material.uniforms.uvTransform.value.copy(v.matrix),(h!==v||c!==v.version)&&(s.material.needsUpdate=!0,h=v,c=v.version),f.unshift(s,s.geometry,s.material,0,0,null))}function l(f,d){t.buffers.color.setClear(f.r,f.g,f.b,d,i)}return{getClearColor:function(){return n},setClearColor:function(f,d){n.set(f),a=d!==void 0?d:1,l(n,a)},getClearAlpha:function(){return a},setClearAlpha:function(f){a=f,l(n,a)},render:u}}function Pl(e,t,r,i){var n;function a(h){n=h}function s(h,c){e.drawArrays(n,h,c),r.update(c,n)}function o(h,c,u){var l;if(i.isWebGL2)l=e;else if(l=t.get("ANGLE_instanced_arrays"),l===null){console.error("THREE.WebGLBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}l[i.isWebGL2?"drawArraysInstanced":"drawArraysInstancedANGLE"](n,c,u,h.maxInstancedCount),r.update(u,n,h.maxInstancedCount)}this.setMode=a,this.render=s,this.renderInstances=o}function Cl(e,t,r){var i;function n(){if(i!==void 0)return i;var R=t.get("EXT_texture_filter_anisotropic");return R!==null?i=e.getParameter(R.MAX_TEXTURE_MAX_ANISOTROPY_EXT):i=0,i}function a(R){if(R==="highp"){if(e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.HIGH_FLOAT).precision>0&&e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.HIGH_FLOAT).precision>0)return"highp";R="mediump"}return R==="mediump"&&e.getShaderPrecisionFormat(e.VERTEX_SHADER,e.MEDIUM_FLOAT).precision>0&&e.getShaderPrecisionFormat(e.FRAGMENT_SHADER,e.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}var s=typeof WebGL2RenderingContext<"u"&&e instanceof WebGL2RenderingContext,o=r.precision!==void 0?r.precision:"highp",h=a(o);h!==o&&(console.warn("THREE.WebGLRenderer:",o,"not supported, using",h,"instead."),o=h);var c=r.logarithmicDepthBuffer===!0,u=e.getParameter(e.MAX_TEXTURE_IMAGE_UNITS),l=e.getParameter(e.MAX_VERTEX_TEXTURE_IMAGE_UNITS),f=e.getParameter(e.MAX_TEXTURE_SIZE),d=e.getParameter(e.MAX_CUBE_MAP_TEXTURE_SIZE),p=e.getParameter(e.MAX_VERTEX_ATTRIBS),m=e.getParameter(e.MAX_VERTEX_UNIFORM_VECTORS),v=e.getParameter(e.MAX_VARYING_VECTORS),g=e.getParameter(e.MAX_FRAGMENT_UNIFORM_VECTORS),_=l>0,w=s||!!t.get("OES_texture_float"),y=_&&w,S=s?e.getParameter(e.MAX_SAMPLES):0;return{isWebGL2:s,getMaxAnisotropy:n,getMaxPrecision:a,precision:o,logarithmicDepthBuffer:c,maxTextures:u,maxVertexTextures:l,maxTextureSize:f,maxCubemapSize:d,maxAttributes:p,maxVertexUniforms:m,maxVaryings:v,maxFragmentUniforms:g,vertexTextures:_,floatFragmentTextures:w,floatVertexTextures:y,maxSamples:S}}function Il(){var e=this,t=null,r=0,i=!1,n=!1,a=new Vt,s=new nt,o={value:null,needsUpdate:!1};this.uniform=o,this.numPlanes=0,this.numIntersection=0,this.init=function(u,l,f){var d=u.length!==0||l||r!==0||i;return i=l,t=c(u,f,0),r=u.length,d},this.beginShadows=function(){n=!0,c(null)},this.endShadows=function(){n=!1,h()},this.setState=function(u,l,f,d,p,m){if(!i||u===null||u.length===0||n&&!f)n?c(null):h();else{var v=n?0:r,g=v*4,_=p.clippingState||null;o.value=_,_=c(u,d,g,m);for(var w=0;w!==g;++w)_[w]=t[w];p.clippingState=_,this.numIntersection=l?this.numPlanes:0,this.numPlanes+=v}};function h(){o.value!==t&&(o.value=t,o.needsUpdate=r>0),e.numPlanes=r,e.numIntersection=0}function c(u,l,f,d){var p=u!==null?u.length:0,m=null;if(p!==0){if(m=o.value,d!==!0||m===null){var v=f+p*4,g=l.matrixWorldInverse;s.getNormalMatrix(g),(m===null||m.length<v)&&(m=new Float32Array(v));for(var _=0,w=f;_!==p;++_,w+=4)a.copy(u[_]).applyMatrix4(g,s),a.normal.toArray(m,w),m[w+3]=a.constant}o.value=m,o.needsUpdate=!0}return e.numPlanes=p,m}}function Dl(e){var t={};return{get:function(r){if(t[r]!==void 0)return t[r];var i;switch(r){case"WEBGL_depth_texture":i=e.getExtension("WEBGL_depth_texture")||e.getExtension("MOZ_WEBGL_depth_texture")||e.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":i=e.getExtension("EXT_texture_filter_anisotropic")||e.getExtension("MOZ_EXT_texture_filter_anisotropic")||e.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":i=e.getExtension("WEBGL_compressed_texture_s3tc")||e.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||e.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":i=e.getExtension("WEBGL_compressed_texture_pvrtc")||e.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:i=e.getExtension(r)}return i===null&&console.warn("THREE.WebGLRenderer: "+r+" extension not supported."),t[r]=i,i}}}function Ol(e,t,r){var i={},n={};function a(c){var u=c.target,l=i[u.id];l.index!==null&&t.remove(l.index);for(var f in l.attributes)t.remove(l.attributes[f]);u.removeEventListener("dispose",a),delete i[u.id];var d=n[l.id];d&&(t.remove(d),delete n[l.id]),r.memory.geometries--}function s(c,u){var l=i[u.id];return l||(u.addEventListener("dispose",a),u.isBufferGeometry?l=u:u.isGeometry&&(u._bufferGeometry===void 0&&(u._bufferGeometry=new $().setFromObject(c)),l=u._bufferGeometry),i[u.id]=l,r.memory.geometries++,l)}function o(c){var u=c.index,l=c.attributes;u!==null&&t.update(u,e.ELEMENT_ARRAY_BUFFER);for(var f in l)t.update(l[f],e.ARRAY_BUFFER);var d=c.morphAttributes;for(var f in d)for(var p=d[f],m=0,v=p.length;m<v;m++)t.update(p[m],e.ARRAY_BUFFER)}function h(c){var u=n[c.id];if(u)return u;var l=[],f=c.index,d=c.attributes;if(f!==null)for(var p=f.array,m=0,v=p.length;m<v;m+=3){var g=p[m+0],_=p[m+1],w=p[m+2];l.push(g,_,_,w,w,g)}else for(var p=d.position.array,m=0,v=p.length/3-1;m<v;m+=3){var g=m+0,_=m+1,w=m+2;l.push(g,_,_,w,w,g)}return u=new(oo(l)>65535?ni:ii)(l,1),t.update(u,e.ELEMENT_ARRAY_BUFFER),n[c.id]=u,u}return{get:s,update:o,getWireframeAttribute:h}}function Fl(e,t,r,i){var n;function a(l){n=l}var s,o;function h(l){s=l.type,o=l.bytesPerElement}function c(l,f){e.drawElements(n,f,s,l*o),r.update(f,n)}function u(l,f,d){var p;if(i.isWebGL2)p=e;else{var p=t.get("ANGLE_instanced_arrays");if(p===null){console.error("THREE.WebGLIndexedBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}}p[i.isWebGL2?"drawElementsInstanced":"drawElementsInstancedANGLE"](n,d,s,f*o,l.maxInstancedCount),r.update(d,n,l.maxInstancedCount)}this.setMode=a,this.setIndex=h,this.render=c,this.renderInstances=u}function Ul(e){var t={geometries:0,textures:0},r={frame:0,calls:0,triangles:0,points:0,lines:0};function i(a,s,o){switch(o=o||1,r.calls++,s){case e.TRIANGLES:r.triangles+=o*(a/3);break;case e.TRIANGLE_STRIP:case e.TRIANGLE_FAN:r.triangles+=o*(a-2);break;case e.LINES:r.lines+=o*(a/2);break;case e.LINE_STRIP:r.lines+=o*(a-1);break;case e.LINE_LOOP:r.lines+=o*a;break;case e.POINTS:r.points+=o*a;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",s);break}}function n(){r.frame++,r.calls=0,r.triangles=0,r.points=0,r.lines=0}return{memory:t,render:r,programs:null,autoReset:!0,reset:n,update:i}}function Bl(e,t){return Math.abs(t[1])-Math.abs(e[1])}function Nl(e){var t={},r=new Float32Array(8);function i(n,a,s,o){var h=n.morphTargetInfluences,c=h.length,u=t[a.id];if(u===void 0){u=[];for(var l=0;l<c;l++)u[l]=[l,0];t[a.id]=u}for(var f=s.morphTargets&&a.morphAttributes.position,d=s.morphNormals&&a.morphAttributes.normal,l=0;l<c;l++){var p=u[l];p[1]!==0&&(f&&a.removeAttribute("morphTarget"+l),d&&a.removeAttribute("morphNormal"+l))}for(var l=0;l<c;l++){var p=u[l];p[0]=l,p[1]=h[l]}u.sort(Bl);for(var l=0;l<8;l++){var p=u[l];if(p){var m=p[0],v=p[1];if(v){f&&a.addAttribute("morphTarget"+l,f[m]),d&&a.addAttribute("morphNormal"+l,d[m]),r[l]=v;continue}}r[l]=0}o.getUniforms().setValue(e,"morphTargetInfluences",r)}return{update:i}}function Gl(e,t){var r={};function i(a){var s=t.render.frame,o=a.geometry,h=e.get(a,o);return r[h.id]!==s&&(o.isGeometry&&h.updateFromObject(a),e.update(h),r[h.id]=s),h}function n(){r={}}return{update:i,dispose:n}}function rr(e,t,r,i,n,a,s,o,h,c){e=e!==void 0?e:[],t=t!==void 0?t:Wa,Ue.call(this,e,t,r,i,n,a,s,o,h,c),this.flipY=!1}rr.prototype=Object.create(Ue.prototype);rr.prototype.constructor=rr;rr.prototype.isCubeTexture=!0;Object.defineProperty(rr.prototype,"images",{get:function(){return this.image},set:function(e){this.image=e}});function ai(e,t,r,i){Ue.call(this,null),this.image={data:e,width:t,height:r,depth:i},this.magFilter=et,this.minFilter=et,this.generateMipmaps=!1,this.flipY=!1}ai.prototype=Object.create(Ue.prototype);ai.prototype.constructor=ai;ai.prototype.isDataTexture3D=!0;var ho=new Ue,zl=new ai,co=new rr;function uo(){this.seq=[],this.map={}}var ds=[],ps=[],ms=new Float32Array(16),vs=new Float32Array(9),gs=new Float32Array(4);function qr(e,t,r){var i=e[0];if(i<=0||i>0)return e;var n=t*r,a=ds[n];if(a===void 0&&(a=new Float32Array(n),ds[n]=a),t!==0){i.toArray(a,0);for(var s=1,o=0;s!==t;++s)o+=r,e[s].toArray(a,o)}return a}function He(e,t){if(e.length!==t.length)return!1;for(var r=0,i=e.length;r<i;r++)if(e[r]!==t[r])return!1;return!0}function tt(e,t){for(var r=0,i=t.length;r<i;r++)e[r]=t[r]}function lo(e,t){var r=ps[t];r===void 0&&(r=new Int32Array(t),ps[t]=r);for(var i=0;i!==t;++i)r[i]=e.allocTextureUnit();return r}function Hl(e,t){var r=this.cache;r[0]!==t&&(e.uniform1f(this.addr,t),r[0]=t)}function Vl(e,t){var r=this.cache;r[0]!==t&&(e.uniform1i(this.addr,t),r[0]=t)}function kl(e,t){var r=this.cache;if(t.x!==void 0)(r[0]!==t.x||r[1]!==t.y)&&(e.uniform2f(this.addr,t.x,t.y),r[0]=t.x,r[1]=t.y);else{if(He(r,t))return;e.uniform2fv(this.addr,t),tt(r,t)}}function Wl(e,t){var r=this.cache;if(t.x!==void 0)(r[0]!==t.x||r[1]!==t.y||r[2]!==t.z)&&(e.uniform3f(this.addr,t.x,t.y,t.z),r[0]=t.x,r[1]=t.y,r[2]=t.z);else if(t.r!==void 0)(r[0]!==t.r||r[1]!==t.g||r[2]!==t.b)&&(e.uniform3f(this.addr,t.r,t.g,t.b),r[0]=t.r,r[1]=t.g,r[2]=t.b);else{if(He(r,t))return;e.uniform3fv(this.addr,t),tt(r,t)}}function Xl(e,t){var r=this.cache;if(t.x!==void 0)(r[0]!==t.x||r[1]!==t.y||r[2]!==t.z||r[3]!==t.w)&&(e.uniform4f(this.addr,t.x,t.y,t.z,t.w),r[0]=t.x,r[1]=t.y,r[2]=t.z,r[3]=t.w);else{if(He(r,t))return;e.uniform4fv(this.addr,t),tt(r,t)}}function jl(e,t){var r=this.cache,i=t.elements;if(i===void 0){if(He(r,t))return;e.uniformMatrix2fv(this.addr,!1,t),tt(r,t)}else{if(He(r,i))return;gs.set(i),e.uniformMatrix2fv(this.addr,!1,gs),tt(r,i)}}function ql(e,t){var r=this.cache,i=t.elements;if(i===void 0){if(He(r,t))return;e.uniformMatrix3fv(this.addr,!1,t),tt(r,t)}else{if(He(r,i))return;vs.set(i),e.uniformMatrix3fv(this.addr,!1,vs),tt(r,i)}}function Yl(e,t){var r=this.cache,i=t.elements;if(i===void 0){if(He(r,t))return;e.uniformMatrix4fv(this.addr,!1,t),tt(r,t)}else{if(He(r,i))return;ms.set(i),e.uniformMatrix4fv(this.addr,!1,ms),tt(r,i)}}function Zl(e,t,r){var i=this.cache,n=r.allocTextureUnit();i[0]!==n&&(e.uniform1i(this.addr,n),i[0]=n),r.setTexture2D(t||ho,n)}function Jl(e,t,r){var i=this.cache,n=r.allocTextureUnit();i[0]!==n&&(e.uniform1i(this.addr,n),i[0]=n),r.setTexture3D(t||zl,n)}function Ql(e,t,r){var i=this.cache,n=r.allocTextureUnit();i[0]!==n&&(e.uniform1i(this.addr,n),i[0]=n),r.setTextureCube(t||co,n)}function fo(e,t){var r=this.cache;He(r,t)||(e.uniform2iv(this.addr,t),tt(r,t))}function po(e,t){var r=this.cache;He(r,t)||(e.uniform3iv(this.addr,t),tt(r,t))}function mo(e,t){var r=this.cache;He(r,t)||(e.uniform4iv(this.addr,t),tt(r,t))}function Kl(e){switch(e){case 5126:return Hl;case 35664:return kl;case 35665:return Wl;case 35666:return Xl;case 35674:return jl;case 35675:return ql;case 35676:return Yl;case 35678:case 36198:return Zl;case 35679:return Jl;case 35680:return Ql;case 5124:case 35670:return Vl;case 35667:case 35671:return fo;case 35668:case 35672:return po;case 35669:case 35673:return mo}}function $l(e,t){var r=this.cache;He(r,t)||(e.uniform1fv(this.addr,t),tt(r,t))}function ef(e,t){var r=this.cache;He(r,t)||(e.uniform1iv(this.addr,t),tt(r,t))}function tf(e,t){var r=this.cache,i=qr(t,this.size,2);He(r,i)||(e.uniform2fv(this.addr,i),this.updateCache(i))}function rf(e,t){var r=this.cache,i=qr(t,this.size,3);He(r,i)||(e.uniform3fv(this.addr,i),this.updateCache(i))}function nf(e,t){var r=this.cache,i=qr(t,this.size,4);He(r,i)||(e.uniform4fv(this.addr,i),this.updateCache(i))}function af(e,t){var r=this.cache,i=qr(t,this.size,4);He(r,i)||(e.uniformMatrix2fv(this.addr,!1,i),this.updateCache(i))}function sf(e,t){var r=this.cache,i=qr(t,this.size,9);He(r,i)||(e.uniformMatrix3fv(this.addr,!1,i),this.updateCache(i))}function of(e,t){var r=this.cache,i=qr(t,this.size,16);He(r,i)||(e.uniformMatrix4fv(this.addr,!1,i),this.updateCache(i))}function hf(e,t,r){var i=this.cache,n=t.length,a=lo(r,n);He(i,a)===!1&&(e.uniform1iv(this.addr,a),tt(i,a));for(var s=0;s!==n;++s)r.setTexture2D(t[s]||ho,a[s])}function cf(e,t,r){var i=this.cache,n=t.length,a=lo(r,n);He(i,a)===!1&&(e.uniform1iv(this.addr,a),tt(i,a));for(var s=0;s!==n;++s)r.setTextureCube(t[s]||co,a[s])}function uf(e){switch(e){case 5126:return $l;case 35664:return tf;case 35665:return rf;case 35666:return nf;case 35674:return af;case 35675:return sf;case 35676:return of;case 35678:return hf;case 35680:return cf;case 5124:case 35670:return ef;case 35667:case 35671:return fo;case 35668:case 35672:return po;case 35669:case 35673:return mo}}function lf(e,t,r){this.id=e,this.addr=r,this.cache=[],this.setValue=Kl(t.type)}function vo(e,t,r){this.id=e,this.addr=r,this.cache=[],this.size=t.size,this.setValue=uf(t.type)}vo.prototype.updateCache=function(e){var t=this.cache;e instanceof Float32Array&&t.length!==e.length&&(this.cache=new Float32Array(e.length)),tt(t,e)};function go(e){this.id=e,uo.call(this)}go.prototype.setValue=function(e,t,r){for(var i=this.seq,n=0,a=i.length;n!==a;++n){var s=i[n];s.setValue(e,t[s.id],r)}};var ea=/([\w\d_]+)(\])?(\[|\.)?/g;function ys(e,t){e.seq.push(t),e.map[t.id]=t}function ff(e,t,r){var i=e.name,n=i.length;for(ea.lastIndex=0;;){var a=ea.exec(i),s=ea.lastIndex,o=a[1],h=a[2]==="]",c=a[3];if(h&&(o=o|0),c===void 0||c==="["&&s+2===n){ys(r,c===void 0?new lf(o,e,t):new vo(o,e,t));break}else{var u=r.map,l=u[o];l===void 0&&(l=new go(o),ys(r,l)),r=l}}}function $t(e,t,r){uo.call(this),this.renderer=r;for(var i=e.getProgramParameter(t,e.ACTIVE_UNIFORMS),n=0;n<i;++n){var a=e.getActiveUniform(t,n),s=e.getUniformLocation(t,a.name);ff(a,s,this)}}$t.prototype.setValue=function(e,t,r){var i=this.map[t];i!==void 0&&i.setValue(e,r,this.renderer)};$t.prototype.setOptional=function(e,t,r){var i=t[r];i!==void 0&&this.setValue(e,r,i)};$t.upload=function(e,t,r,i){for(var n=0,a=t.length;n!==a;++n){var s=t[n],o=r[s.id];o.needsUpdate!==!1&&s.setValue(e,o.value,i)}};$t.seqWithValue=function(e,t){for(var r=[],i=0,n=e.length;i!==n;++i){var a=e[i];a.id in t&&r.push(a)}return r};function df(e){for(var t=e.split(`
`),r=0;r<t.length;r++)t[r]=r+1+": "+t[r];return t.join(`
`)}function xs(e,t,r){var i=e.createShader(t);return e.shaderSource(i,r),e.compileShader(i),e.getShaderParameter(i,e.COMPILE_STATUS)===!1&&console.error("THREE.WebGLShader: Shader couldn't compile."),e.getShaderInfoLog(i)!==""&&console.warn("THREE.WebGLShader: gl.getShaderInfoLog()",t===e.VERTEX_SHADER?"vertex":"fragment",e.getShaderInfoLog(i),df(r)),i}var pf=0;function yo(e){switch(e){case $i:return["Linear","( value )"];case ic:return["sRGB","( value )"];case nc:return["RGBE","( value )"];case ac:return["RGBM","( value, 7.0 )"];case sc:return["RGBM","( value, 16.0 )"];case oc:return["RGBD","( value, 256.0 )"];case no:return["Gamma","( value, float( GAMMA_FACTOR ) )"];default:throw new Error("unsupported encoding: "+e)}}function Wi(e,t){var r=yo(t);return"vec4 "+e+"( vec4 value ) { return "+r[0]+"ToLinear"+r[1]+"; }"}function mf(e,t){var r=yo(t);return"vec4 "+e+"( vec4 value ) { return LinearTo"+r[0]+r[1]+"; }"}function vf(e,t){var r;switch(t){case Ks:r="Linear";break;case Mh:r="Reinhard";break;case Eh:r="Uncharted2";break;case Th:r="OptimizedCineon";break;case Sh:r="ACESFilmic";break;default:throw new Error("unsupported toneMapping: "+t)}return"vec3 "+e+"( vec3 color ) { return "+r+"ToneMapping( color ); }"}function gf(e,t,r){e=e||{};var i=[e.derivatives||t.envMapCubeUV||t.bumpMap||t.normalMap&&!t.objectSpaceNormalMap||t.flatShading?"#extension GL_OES_standard_derivatives : enable":"",(e.fragDepth||t.logarithmicDepthBuffer)&&r.get("EXT_frag_depth")?"#extension GL_EXT_frag_depth : enable":"",e.drawBuffers&&r.get("WEBGL_draw_buffers")?"#extension GL_EXT_draw_buffers : require":"",(e.shaderTextureLOD||t.envMap)&&r.get("EXT_shader_texture_lod")?"#extension GL_EXT_shader_texture_lod : enable":""];return i.filter(Zr).join(`
`)}function yf(e){var t=[];for(var r in e){var i=e[r];i!==!1&&t.push("#define "+r+" "+i)}return t.join(`
`)}function xf(e,t){for(var r={},i=e.getProgramParameter(t,e.ACTIVE_ATTRIBUTES),n=0;n<i;n++){var a=e.getActiveAttrib(t,n),s=a.name;r[s]=e.getAttribLocation(t,s)}return r}function Zr(e){return e!==""}function _s(e,t){return e.replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights)}function ws(e,t){return e.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}function ya(e){var t=/^[ \t]*#include +<([\w\d./]+)>/gm;function r(i,n){var a=Te[n];if(a===void 0)throw new Error("Can not resolve #include <"+n+">");return ya(a)}return e.replace(t,r)}function bs(e){var t=/#pragma unroll_loop[\s]+?for \( int i \= (\d+)\; i < (\d+)\; i \+\+ \) \{([\s\S]+?)(?=\})\}/g;function r(i,n,a,s){for(var o="",h=parseInt(n);h<parseInt(a);h++)o+=s.replace(/\[ i \]/g,"[ "+h+" ]");return o}return e.replace(t,r)}function _f(e,t,r,i,n,a,s){var o=e.context,h=i.defines,c=n.vertexShader,u=n.fragmentShader,l="SHADOWMAP_TYPE_BASIC";a.shadowMapType===Xs?l="SHADOWMAP_TYPE_PCF":a.shadowMapType===rh&&(l="SHADOWMAP_TYPE_PCF_SOFT");var f="ENVMAP_TYPE_CUBE",d="ENVMAP_MODE_REFLECTION",p="ENVMAP_BLENDING_MULTIPLY";if(a.envMap){switch(i.envMap.mapping){case Wa:case ua:f="ENVMAP_TYPE_CUBE";break;case Xa:case ja:f="ENVMAP_TYPE_CUBE_UV";break;case $s:case la:f="ENVMAP_TYPE_EQUIREC";break;case eo:f="ENVMAP_TYPE_SPHERE";break}switch(i.envMap.mapping){case ua:case la:d="ENVMAP_MODE_REFRACTION";break}switch(i.combine){case Hn:p="ENVMAP_BLENDING_MULTIPLY";break;case wh:p="ENVMAP_BLENDING_MIX";break;case bh:p="ENVMAP_BLENDING_ADD";break}}var m=e.gammaFactor>0?e.gammaFactor:1,v=s.isWebGL2?"":gf(i.extensions,a,t),g=yf(h),_=o.createProgram(),w,y;if(i.isRawShaderMaterial?(w=[g].filter(Zr).join(`
`),w.length>0&&(w+=`
`),y=[v,g].filter(Zr).join(`
`),y.length>0&&(y+=`
`)):(w=["precision "+a.precision+" float;","precision "+a.precision+" int;","#define SHADER_NAME "+n.name,g,a.supportsVertexTextures?"#define VERTEX_TEXTURES":"","#define GAMMA_FACTOR "+m,"#define MAX_BONES "+a.maxBones,a.useFog&&a.fog?"#define USE_FOG":"",a.useFog&&a.fogExp?"#define FOG_EXP2":"",a.map?"#define USE_MAP":"",a.envMap?"#define USE_ENVMAP":"",a.envMap?"#define "+d:"",a.lightMap?"#define USE_LIGHTMAP":"",a.aoMap?"#define USE_AOMAP":"",a.emissiveMap?"#define USE_EMISSIVEMAP":"",a.bumpMap?"#define USE_BUMPMAP":"",a.normalMap?"#define USE_NORMALMAP":"",a.normalMap&&a.objectSpaceNormalMap?"#define OBJECTSPACE_NORMALMAP":"",a.displacementMap&&a.supportsVertexTextures?"#define USE_DISPLACEMENTMAP":"",a.specularMap?"#define USE_SPECULARMAP":"",a.roughnessMap?"#define USE_ROUGHNESSMAP":"",a.metalnessMap?"#define USE_METALNESSMAP":"",a.alphaMap?"#define USE_ALPHAMAP":"",a.vertexColors?"#define USE_COLOR":"",a.flatShading?"#define FLAT_SHADED":"",a.skinning?"#define USE_SKINNING":"",a.useVertexTexture?"#define BONE_TEXTURE":"",a.morphTargets?"#define USE_MORPHTARGETS":"",a.morphNormals&&a.flatShading===!1?"#define USE_MORPHNORMALS":"",a.doubleSided?"#define DOUBLE_SIDED":"",a.flipSided?"#define FLIP_SIDED":"",a.shadowMapEnabled?"#define USE_SHADOWMAP":"",a.shadowMapEnabled?"#define "+l:"",a.sizeAttenuation?"#define USE_SIZEATTENUATION":"",a.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",a.logarithmicDepthBuffer&&(s.isWebGL2||t.get("EXT_frag_depth"))?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_COLOR","	attribute vec3 color;","#endif","#ifdef USE_MORPHTARGETS","	attribute vec3 morphTarget0;","	attribute vec3 morphTarget1;","	attribute vec3 morphTarget2;","	attribute vec3 morphTarget3;","	#ifdef USE_MORPHNORMALS","		attribute vec3 morphNormal0;","		attribute vec3 morphNormal1;","		attribute vec3 morphNormal2;","		attribute vec3 morphNormal3;","	#else","		attribute vec3 morphTarget4;","		attribute vec3 morphTarget5;","		attribute vec3 morphTarget6;","		attribute vec3 morphTarget7;","	#endif","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(Zr).join(`
`),y=[v,"precision "+a.precision+" float;","precision "+a.precision+" int;","#define SHADER_NAME "+n.name,g,a.alphaTest?"#define ALPHATEST "+a.alphaTest+(a.alphaTest%1?"":".0"):"","#define GAMMA_FACTOR "+m,a.useFog&&a.fog?"#define USE_FOG":"",a.useFog&&a.fogExp?"#define FOG_EXP2":"",a.map?"#define USE_MAP":"",a.matcap?"#define USE_MATCAP":"",a.envMap?"#define USE_ENVMAP":"",a.envMap?"#define "+f:"",a.envMap?"#define "+d:"",a.envMap?"#define "+p:"",a.lightMap?"#define USE_LIGHTMAP":"",a.aoMap?"#define USE_AOMAP":"",a.emissiveMap?"#define USE_EMISSIVEMAP":"",a.bumpMap?"#define USE_BUMPMAP":"",a.normalMap?"#define USE_NORMALMAP":"",a.normalMap&&a.objectSpaceNormalMap?"#define OBJECTSPACE_NORMALMAP":"",a.specularMap?"#define USE_SPECULARMAP":"",a.roughnessMap?"#define USE_ROUGHNESSMAP":"",a.metalnessMap?"#define USE_METALNESSMAP":"",a.alphaMap?"#define USE_ALPHAMAP":"",a.vertexColors?"#define USE_COLOR":"",a.gradientMap?"#define USE_GRADIENTMAP":"",a.flatShading?"#define FLAT_SHADED":"",a.doubleSided?"#define DOUBLE_SIDED":"",a.flipSided?"#define FLIP_SIDED":"",a.shadowMapEnabled?"#define USE_SHADOWMAP":"",a.shadowMapEnabled?"#define "+l:"",a.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",a.physicallyCorrectLights?"#define PHYSICALLY_CORRECT_LIGHTS":"",a.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",a.logarithmicDepthBuffer&&(s.isWebGL2||t.get("EXT_frag_depth"))?"#define USE_LOGDEPTHBUF_EXT":"",a.envMap&&(s.isWebGL2||t.get("EXT_shader_texture_lod"))?"#define TEXTURE_LOD_EXT":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;",a.toneMapping!==Kn?"#define TONE_MAPPING":"",a.toneMapping!==Kn?Te.tonemapping_pars_fragment:"",a.toneMapping!==Kn?vf("toneMapping",a.toneMapping):"",a.dithering?"#define DITHERING":"",a.outputEncoding||a.mapEncoding||a.matcapEncoding||a.envMapEncoding||a.emissiveMapEncoding?Te.encodings_pars_fragment:"",a.mapEncoding?Wi("mapTexelToLinear",a.mapEncoding):"",a.matcapEncoding?Wi("matcapTexelToLinear",a.matcapEncoding):"",a.envMapEncoding?Wi("envMapTexelToLinear",a.envMapEncoding):"",a.emissiveMapEncoding?Wi("emissiveMapTexelToLinear",a.emissiveMapEncoding):"",a.outputEncoding?mf("linearToOutputTexel",a.outputEncoding):"",a.depthPacking?"#define DEPTH_PACKING "+i.depthPacking:"",`
`].filter(Zr).join(`
`)),c=ya(c),c=_s(c,a),c=ws(c,a),u=ya(u),u=_s(u,a),u=ws(u,a),c=bs(c),u=bs(u),s.isWebGL2&&!i.isRawShaderMaterial){var S=!1,R=/^\s*#version\s+300\s+es\s*\n/;i.isShaderMaterial&&c.match(R)!==null&&u.match(R)!==null&&(S=!0,c=c.replace(R,""),u=u.replace(R,"")),w=[`#version 300 es
`,"#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+w,y=[`#version 300 es
`,"#define varying in",S?"":"out highp vec4 pc_fragColor;",S?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+y}var I=w+c,C=y+u,A=xs(o,o.VERTEX_SHADER,I),O=xs(o,o.FRAGMENT_SHADER,C);o.attachShader(_,A),o.attachShader(_,O),i.index0AttributeName!==void 0?o.bindAttribLocation(_,0,i.index0AttributeName):a.morphTargets===!0&&o.bindAttribLocation(_,0,"position"),o.linkProgram(_);var F=o.getProgramInfoLog(_).trim(),N=o.getShaderInfoLog(A).trim(),V=o.getShaderInfoLog(O).trim(),k=!0,G=!0;o.getProgramParameter(_,o.LINK_STATUS)===!1?(k=!1,console.error("THREE.WebGLProgram: shader error: ",o.getError(),"gl.VALIDATE_STATUS",o.getProgramParameter(_,o.VALIDATE_STATUS),"gl.getProgramInfoLog",F,N,V)):F!==""?console.warn("THREE.WebGLProgram: gl.getProgramInfoLog()",F):(N===""||V==="")&&(G=!1),G&&(this.diagnostics={runnable:k,material:i,programLog:F,vertexShader:{log:N,prefix:w},fragmentShader:{log:V,prefix:y}}),o.deleteShader(A),o.deleteShader(O);var J;this.getUniforms=function(){return J===void 0&&(J=new $t(o,_,e)),J};var Y;return this.getAttributes=function(){return Y===void 0&&(Y=xf(o,_)),Y},this.destroy=function(){o.deleteProgram(_),this.program=void 0},Object.defineProperties(this,{uniforms:{get:function(){return console.warn("THREE.WebGLProgram: .uniforms is now .getUniforms()."),this.getUniforms()}},attributes:{get:function(){return console.warn("THREE.WebGLProgram: .attributes is now .getAttributes()."),this.getAttributes()}}}),this.name=n.name,this.id=pf++,this.code=r,this.usedTimes=1,this.program=_,this.vertexShader=A,this.fragmentShader=O,this}function wf(e,t,r){var i=[],n={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"phong",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"},a=["precision","supportsVertexTextures","map","mapEncoding","matcap","matcapEncoding","envMap","envMapMode","envMapEncoding","lightMap","aoMap","emissiveMap","emissiveMapEncoding","bumpMap","normalMap","objectSpaceNormalMap","displacementMap","specularMap","roughnessMap","metalnessMap","gradientMap","alphaMap","combine","vertexColors","fog","useFog","fogExp","flatShading","sizeAttenuation","logarithmicDepthBuffer","skinning","maxBones","useVertexTexture","morphTargets","morphNormals","maxMorphTargets","maxMorphNormals","premultipliedAlpha","numDirLights","numPointLights","numSpotLights","numHemiLights","numRectAreaLights","shadowMapEnabled","shadowMapType","toneMapping","physicallyCorrectLights","alphaTest","doubleSided","flipSided","numClippingPlanes","numClipIntersection","depthPacking","dithering"];function s(h){var c=h.skeleton,u=c.bones;if(r.floatVertexTextures)return 1024;var l=r.maxVertexUniforms,f=Math.floor((l-20)/4),d=Math.min(f,u.length);return d<u.length?(console.warn("THREE.WebGLRenderer: Skeleton has "+u.length+" bones. This GPU supports "+d+"."),0):d}function o(h,c){var u;return h?h.isTexture?u=h.encoding:h.isWebGLRenderTarget&&(console.warn("THREE.WebGLPrograms.getTextureEncodingFromMap: don't use render targets as textures. Use their .texture property instead."),u=h.texture.encoding):u=$i,u===$i&&c&&(u=no),u}this.getParameters=function(h,c,u,l,f,d,p){var m=n[h.type],v=p.isSkinnedMesh?s(p):0,g=r.precision;h.precision!==null&&(g=r.getMaxPrecision(h.precision),g!==h.precision&&console.warn("THREE.WebGLProgram.getParameters:",h.precision,"not supported, using",g,"instead."));var _=e.getRenderTarget(),w={shaderID:m,precision:g,supportsVertexTextures:r.vertexTextures,outputEncoding:o(_?_.texture:null,e.gammaOutput),map:!!h.map,mapEncoding:o(h.map,e.gammaInput),matcap:!!h.matcap,matcapEncoding:o(h.matcap,e.gammaInput),envMap:!!h.envMap,envMapMode:h.envMap&&h.envMap.mapping,envMapEncoding:o(h.envMap,e.gammaInput),envMapCubeUV:!!h.envMap&&(h.envMap.mapping===Xa||h.envMap.mapping===ja),lightMap:!!h.lightMap,aoMap:!!h.aoMap,emissiveMap:!!h.emissiveMap,emissiveMapEncoding:o(h.emissiveMap,e.gammaInput),bumpMap:!!h.bumpMap,normalMap:!!h.normalMap,objectSpaceNormalMap:h.normalMapType===uc,displacementMap:!!h.displacementMap,roughnessMap:!!h.roughnessMap,metalnessMap:!!h.metalnessMap,specularMap:!!h.specularMap,alphaMap:!!h.alphaMap,gradientMap:!!h.gradientMap,combine:h.combine,vertexColors:h.vertexColors,fog:!!l,useFog:h.fog,fogExp:l&&l.isFogExp2,flatShading:h.flatShading,sizeAttenuation:h.sizeAttenuation,logarithmicDepthBuffer:r.logarithmicDepthBuffer,skinning:h.skinning&&v>0,maxBones:v,useVertexTexture:r.floatVertexTextures,morphTargets:h.morphTargets,morphNormals:h.morphNormals,maxMorphTargets:e.maxMorphTargets,maxMorphNormals:e.maxMorphNormals,numDirLights:c.directional.length,numPointLights:c.point.length,numSpotLights:c.spot.length,numRectAreaLights:c.rectArea.length,numHemiLights:c.hemi.length,numClippingPlanes:f,numClipIntersection:d,dithering:h.dithering,shadowMapEnabled:e.shadowMap.enabled&&p.receiveShadow&&u.length>0,shadowMapType:e.shadowMap.type,toneMapping:e.toneMapping,physicallyCorrectLights:e.physicallyCorrectLights,premultipliedAlpha:h.premultipliedAlpha,alphaTest:h.alphaTest,doubleSided:h.side===Ni,flipSided:h.side===st,depthPacking:h.depthPacking!==void 0?h.depthPacking:!1};return w},this.getProgramCode=function(h,c){var u=[];if(c.shaderID?u.push(c.shaderID):(u.push(h.fragmentShader),u.push(h.vertexShader)),h.defines!==void 0)for(var l in h.defines)u.push(l),u.push(h.defines[l]);for(var f=0;f<a.length;f++)u.push(c[a[f]]);return u.push(h.onBeforeCompile.toString()),u.push(e.gammaOutput),u.push(e.gammaFactor),u.join()},this.acquireProgram=function(h,c,u,l){for(var f,d=0,p=i.length;d<p;d++){var m=i[d];if(m.code===l){f=m,++f.usedTimes;break}}return f===void 0&&(f=new _f(e,t,l,h,c,u,r),i.push(f)),f},this.releaseProgram=function(h){if(--h.usedTimes===0){var c=i.indexOf(h);i[c]=i[i.length-1],i.pop(),h.destroy()}},this.programs=i}function bf(){var e=new WeakMap;function t(a){var s=e.get(a);return s===void 0&&(s={},e.set(a,s)),s}function r(a){e.delete(a)}function i(a,s,o){e.get(a)[s]=o}function n(){e=new WeakMap}return{get:t,remove:r,update:i,dispose:n}}function Mf(e,t){return e.groupOrder!==t.groupOrder?e.groupOrder-t.groupOrder:e.renderOrder!==t.renderOrder?e.renderOrder-t.renderOrder:e.program&&t.program&&e.program!==t.program?e.program.id-t.program.id:e.material.id!==t.material.id?e.material.id-t.material.id:e.z!==t.z?e.z-t.z:e.id-t.id}function Ef(e,t){return e.groupOrder!==t.groupOrder?e.groupOrder-t.groupOrder:e.renderOrder!==t.renderOrder?e.renderOrder-t.renderOrder:e.z!==t.z?t.z-e.z:e.id-t.id}function Ms(){var e=[],t=0,r=[],i=[];function n(){t=0,r.length=0,i.length=0}function a(c,u,l,f,d,p){var m=e[t];return m===void 0?(m={id:c.id,object:c,geometry:u,material:l,program:l.program,groupOrder:f,renderOrder:c.renderOrder,z:d,group:p},e[t]=m):(m.id=c.id,m.object=c,m.geometry=u,m.material=l,m.program=l.program,m.groupOrder=f,m.renderOrder=c.renderOrder,m.z=d,m.group=p),t++,m}function s(c,u,l,f,d,p){var m=a(c,u,l,f,d,p);(l.transparent===!0?i:r).push(m)}function o(c,u,l,f,d,p){var m=a(c,u,l,f,d,p);(l.transparent===!0?i:r).unshift(m)}function h(){r.length>1&&r.sort(Mf),i.length>1&&i.sort(Ef)}return{opaque:r,transparent:i,init:n,push:s,unshift:o,sort:h}}function Tf(){var e={};function t(n){var a=n.target;a.removeEventListener("dispose",t),delete e[a.id]}function r(n,a){var s=e[n.id],o;return s===void 0?(o=new Ms,e[n.id]={},e[n.id][a.id]=o,n.addEventListener("dispose",t)):(o=s[a.id],o===void 0&&(o=new Ms,s[a.id]=o)),o}function i(){e={}}return{get:r,dispose:i}}function Sf(){var e={};return{get:function(t){if(e[t.id]!==void 0)return e[t.id];var r;switch(t.type){case"DirectionalLight":r={direction:new b,color:new oe,shadow:!1,shadowBias:0,shadowRadius:1,shadowMapSize:new z};break;case"SpotLight":r={position:new b,direction:new b,color:new oe,distance:0,coneCos:0,penumbraCos:0,decay:0,shadow:!1,shadowBias:0,shadowRadius:1,shadowMapSize:new z};break;case"PointLight":r={position:new b,color:new oe,distance:0,decay:0,shadow:!1,shadowBias:0,shadowRadius:1,shadowMapSize:new z,shadowCameraNear:1,shadowCameraFar:1e3};break;case"HemisphereLight":r={direction:new b,skyColor:new oe,groundColor:new oe};break;case"RectAreaLight":r={color:new oe,position:new b,halfWidth:new b,halfHeight:new b};break}return e[t.id]=r,r}}}var Af=0;function Lf(){var e=new Sf,t={id:Af++,hash:{stateID:-1,directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,shadowsLength:-1},ambient:[0,0,0],directional:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotShadowMap:[],spotShadowMatrix:[],rectArea:[],point:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[]},r=new b,i=new fe,n=new fe;function a(s,o,h){for(var c=0,u=0,l=0,f=0,d=0,p=0,m=0,v=0,g=h.matrixWorldInverse,_=0,w=s.length;_<w;_++){var y=s[_],S=y.color,R=y.intensity,I=y.distance,C=y.shadow&&y.shadow.map?y.shadow.map.texture:null;if(y.isAmbientLight)c+=S.r*R,u+=S.g*R,l+=S.b*R;else if(y.isDirectionalLight){var A=e.get(y);if(A.color.copy(y.color).multiplyScalar(y.intensity),A.direction.setFromMatrixPosition(y.matrixWorld),r.setFromMatrixPosition(y.target.matrixWorld),A.direction.sub(r),A.direction.transformDirection(g),A.shadow=y.castShadow,y.castShadow){var O=y.shadow;A.shadowBias=O.bias,A.shadowRadius=O.radius,A.shadowMapSize=O.mapSize}t.directionalShadowMap[f]=C,t.directionalShadowMatrix[f]=y.shadow.matrix,t.directional[f]=A,f++}else if(y.isSpotLight){var A=e.get(y);if(A.position.setFromMatrixPosition(y.matrixWorld),A.position.applyMatrix4(g),A.color.copy(S).multiplyScalar(R),A.distance=I,A.direction.setFromMatrixPosition(y.matrixWorld),r.setFromMatrixPosition(y.target.matrixWorld),A.direction.sub(r),A.direction.transformDirection(g),A.coneCos=Math.cos(y.angle),A.penumbraCos=Math.cos(y.angle*(1-y.penumbra)),A.decay=y.decay,A.shadow=y.castShadow,y.castShadow){var O=y.shadow;A.shadowBias=O.bias,A.shadowRadius=O.radius,A.shadowMapSize=O.mapSize}t.spotShadowMap[p]=C,t.spotShadowMatrix[p]=y.shadow.matrix,t.spot[p]=A,p++}else if(y.isRectAreaLight){var A=e.get(y);A.color.copy(S).multiplyScalar(R),A.position.setFromMatrixPosition(y.matrixWorld),A.position.applyMatrix4(g),n.identity(),i.copy(y.matrixWorld),i.premultiply(g),n.extractRotation(i),A.halfWidth.set(y.width*.5,0,0),A.halfHeight.set(0,y.height*.5,0),A.halfWidth.applyMatrix4(n),A.halfHeight.applyMatrix4(n),t.rectArea[m]=A,m++}else if(y.isPointLight){var A=e.get(y);if(A.position.setFromMatrixPosition(y.matrixWorld),A.position.applyMatrix4(g),A.color.copy(y.color).multiplyScalar(y.intensity),A.distance=y.distance,A.decay=y.decay,A.shadow=y.castShadow,y.castShadow){var O=y.shadow;A.shadowBias=O.bias,A.shadowRadius=O.radius,A.shadowMapSize=O.mapSize,A.shadowCameraNear=O.camera.near,A.shadowCameraFar=O.camera.far}t.pointShadowMap[d]=C,t.pointShadowMatrix[d]=y.shadow.matrix,t.point[d]=A,d++}else if(y.isHemisphereLight){var A=e.get(y);A.direction.setFromMatrixPosition(y.matrixWorld),A.direction.transformDirection(g),A.direction.normalize(),A.skyColor.copy(y.color).multiplyScalar(R),A.groundColor.copy(y.groundColor).multiplyScalar(R),t.hemi[v]=A,v++}}t.ambient[0]=c,t.ambient[1]=u,t.ambient[2]=l,t.directional.length=f,t.spot.length=p,t.rectArea.length=m,t.point.length=d,t.hemi.length=v,t.hash.stateID=t.id,t.hash.directionalLength=f,t.hash.pointLength=d,t.hash.spotLength=p,t.hash.rectAreaLength=m,t.hash.hemiLength=v,t.hash.shadowsLength=o.length}return{setup:a,state:t}}function Es(){var e=new Lf,t=[],r=[];function i(){t.length=0,r.length=0}function n(h){t.push(h)}function a(h){r.push(h)}function s(h){e.setup(t,r,h)}var o={lightsArray:t,shadowsArray:r,lights:e};return{init:i,state:o,setupLights:s,pushLight:n,pushShadow:a}}function Rf(){var e={};function t(n){var a=n.target;a.removeEventListener("dispose",t),delete e[a.id]}function r(n,a){var s;return e[n.id]===void 0?(s=new Es,e[n.id]={},e[n.id][a.id]=s,n.addEventListener("dispose",t)):e[n.id][a.id]===void 0?(s=new Es,e[n.id][a.id]=s):s=e[n.id][a.id],s}function i(){e={}}return{get:r,dispose:i}}function fr(e){ve.call(this),this.type="MeshDepthMaterial",this.depthPacking=hc,this.skinning=!1,this.morphTargets=!1,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.setValues(e)}fr.prototype=Object.create(ve.prototype);fr.prototype.constructor=fr;fr.prototype.isMeshDepthMaterial=!0;fr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.depthPacking=e.depthPacking,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this};function dr(e){ve.call(this),this.type="MeshDistanceMaterial",this.referencePosition=new b,this.nearDistance=1,this.farDistance=1e3,this.skinning=!1,this.morphTargets=!1,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.fog=!1,this.lights=!1,this.setValues(e)}dr.prototype=Object.create(ve.prototype);dr.prototype.constructor=dr;dr.prototype.isMeshDistanceMaterial=!0;dr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.referencePosition.copy(e.referencePosition),this.nearDistance=e.nearDistance,this.farDistance=e.farDistance,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.map=e.map,this.alphaMap=e.alphaMap,this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this};function xo(e,t,r){for(var i=new Ja,n=new fe,a=new z,s=new z(r,r),o=new b,h=new b,c=1,u=2,l=(c|u)+1,f=new Array(l),d=new Array(l),p={},m={0:st,1:Bi,2:Ni},v=[new b(1,0,0),new b(-1,0,0),new b(0,0,1),new b(0,0,-1),new b(0,1,0),new b(0,-1,0)],g=[new b(0,1,0),new b(0,1,0),new b(0,1,0),new b(0,1,0),new b(0,0,1),new b(0,0,-1)],_=[new Fe,new Fe,new Fe,new Fe,new Fe,new Fe],w=0;w!==l;++w){var y=(w&c)!==0,S=(w&u)!==0,R=new fr({depthPacking:cc,morphTargets:y,skinning:S});f[w]=R;var I=new dr({morphTargets:y,skinning:S});d[w]=I}var C=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=Xs,this.render=function(F,N,V){if(C.enabled!==!1&&!(C.autoUpdate===!1&&C.needsUpdate===!1)&&F.length!==0){var k=e.state;k.setBlending(Jr),k.buffers.color.setClear(1,1,1,1),k.buffers.depth.setTest(!0),k.setScissorTest(!1);for(var G,J=0,Y=F.length;J<Y;J++){var q=F[J],E=q.shadow,T=q&&q.isPointLight;if(E===void 0){console.warn("THREE.WebGLShadowMap:",q,"has no shadow.");continue}var U=E.camera;if(a.copy(E.mapSize),a.min(s),T){var L=a.x,Q=a.y;_[0].set(L*2,Q,L,Q),_[1].set(0,Q,L,Q),_[2].set(L*3,Q,L,Q),_[3].set(L,Q,L,Q),_[4].set(L*3,0,L,Q),_[5].set(L,0,L,Q),a.x*=4,a.y*=2}if(E.map===null){var B={minFilter:et,magFilter:et,format:Wt};E.map=new Dt(a.x,a.y,B),E.map.texture.name=q.name+".shadowMap",U.updateProjectionMatrix()}E.isSpotLightShadow&&E.update(q);var W=E.map,j=E.matrix;h.setFromMatrixPosition(q.matrixWorld),U.position.copy(h),T?(G=6,j.makeTranslation(-h.x,-h.y,-h.z)):(G=1,o.setFromMatrixPosition(q.target.matrixWorld),U.lookAt(o),U.updateMatrixWorld(),j.set(.5,0,0,.5,0,.5,0,.5,0,0,.5,.5,0,0,0,1),j.multiply(U.projectionMatrix),j.multiply(U.matrixWorldInverse)),e.setRenderTarget(W),e.clear();for(var pe=0;pe<G;pe++){if(T){o.copy(U.position),o.add(v[pe]),U.up.copy(g[pe]),U.lookAt(o),U.updateMatrixWorld();var me=_[pe];k.viewport(me)}n.multiplyMatrices(U.projectionMatrix,U.matrixWorldInverse),i.setFromMatrix(n),O(N,V,U,T)}}C.needsUpdate=!1}};function A(F,N,V,k,G,J){var Y=F.geometry,q=null,E=f,T=F.customDepthMaterial;if(V&&(E=d,T=F.customDistanceMaterial),T)q=T;else{var U=!1;N.morphTargets&&(Y&&Y.isBufferGeometry?U=Y.morphAttributes&&Y.morphAttributes.position&&Y.morphAttributes.position.length>0:Y&&Y.isGeometry&&(U=Y.morphTargets&&Y.morphTargets.length>0)),F.isSkinnedMesh&&N.skinning===!1&&console.warn("THREE.WebGLShadowMap: THREE.SkinnedMesh with material.skinning set to false:",F);var L=F.isSkinnedMesh&&N.skinning,Q=0;U&&(Q|=c),L&&(Q|=u),q=E[Q]}if(e.localClippingEnabled&&N.clipShadows===!0&&N.clippingPlanes.length!==0){var B=q.uuid,W=N.uuid,j=p[B];j===void 0&&(j={},p[B]=j);var pe=j[W];pe===void 0&&(pe=q.clone(),j[W]=pe),q=pe}return q.visible=N.visible,q.wireframe=N.wireframe,q.side=N.shadowSide!=null?N.shadowSide:m[N.side],q.clipShadows=N.clipShadows,q.clippingPlanes=N.clippingPlanes,q.clipIntersection=N.clipIntersection,q.wireframeLinewidth=N.wireframeLinewidth,q.linewidth=N.linewidth,V&&q.isMeshDistanceMaterial&&(q.referencePosition.copy(k),q.nearDistance=G,q.farDistance=J),q}function O(F,N,V,k){if(F.visible!==!1){var G=F.layers.test(N.layers);if(G&&(F.isMesh||F.isLine||F.isPoints)&&F.castShadow&&(!F.frustumCulled||i.intersectsObject(F))){F.modelViewMatrix.multiplyMatrices(V.matrixWorldInverse,F.matrixWorld);var J=t.update(F),Y=F.material;if(Array.isArray(Y))for(var q=J.groups,E=0,T=q.length;E<T;E++){var U=q[E],L=Y[U.materialIndex];if(L&&L.visible){var Q=A(F,L,k,h,V.near,V.far);e.renderBufferDirect(V,null,J,Q,F,U)}}else if(Y.visible){var Q=A(F,Y,k,h,V.near,V.far);e.renderBufferDirect(V,null,J,Q,F,null)}}for(var B=F.children,W=0,j=B.length;W<j;W++)O(B[W],N,V,k)}}}function Pf(e,t,r,i){function n(){var D=!1,te=new Fe,ne=null,we=new Fe(0,0,0,0);return{setMask:function(se){ne!==se&&!D&&(e.colorMask(se,se,se,se),ne=se)},setLocked:function(se){D=se},setClear:function(se,Ee,Ie,Ce,pt){pt===!0&&(se*=Ce,Ee*=Ce,Ie*=Ce),te.set(se,Ee,Ie,Ce),we.equals(te)===!1&&(e.clearColor(se,Ee,Ie,Ce),we.copy(te))},reset:function(){D=!1,ne=null,we.set(-1,0,0,0)}}}function a(){var D=!1,te=null,ne=null,we=null;return{setTest:function(se){se?le(e.DEPTH_TEST):H(e.DEPTH_TEST)},setMask:function(se){te!==se&&!D&&(e.depthMask(se),te=se)},setFunc:function(se){if(ne!==se){if(se)switch(se){case ph:e.depthFunc(e.NEVER);break;case mh:e.depthFunc(e.ALWAYS);break;case vh:e.depthFunc(e.LESS);break;case ca:e.depthFunc(e.LEQUAL);break;case gh:e.depthFunc(e.EQUAL);break;case yh:e.depthFunc(e.GEQUAL);break;case xh:e.depthFunc(e.GREATER);break;case _h:e.depthFunc(e.NOTEQUAL);break;default:e.depthFunc(e.LEQUAL)}else e.depthFunc(e.LEQUAL);ne=se}},setLocked:function(se){D=se},setClear:function(se){we!==se&&(e.clearDepth(se),we=se)},reset:function(){D=!1,te=null,ne=null,we=null}}}function s(){var D=!1,te=null,ne=null,we=null,se=null,Ee=null,Ie=null,Ce=null,pt=null;return{setTest:function(De){De?le(e.STENCIL_TEST):H(e.STENCIL_TEST)},setMask:function(De){te!==De&&!D&&(e.stencilMask(De),te=De)},setFunc:function(De,gt,qe){(ne!==De||we!==gt||se!==qe)&&(e.stencilFunc(De,gt,qe),ne=De,we=gt,se=qe)},setOp:function(De,gt,qe){(Ee!==De||Ie!==gt||Ce!==qe)&&(e.stencilOp(De,gt,qe),Ee=De,Ie=gt,Ce=qe)},setLocked:function(De){D=De},setClear:function(De){pt!==De&&(e.clearStencil(De),pt=De)},reset:function(){D=!1,te=null,ne=null,we=null,se=null,Ee=null,Ie=null,Ce=null,pt=null}}}var o=new n,h=new a,c=new s,u=e.getParameter(e.MAX_VERTEX_ATTRIBS),l=new Uint8Array(u),f=new Uint8Array(u),d=new Uint8Array(u),p={},m=null,v=null,g=null,_=null,w=null,y=null,S=null,R=null,I=null,C=null,A=!1,O=null,F=null,N=null,V=null,k=null,G=e.getParameter(e.MAX_COMBINED_TEXTURE_IMAGE_UNITS),J=!1,Y=0,q=e.getParameter(e.VERSION);q.indexOf("WebGL")!==-1?(Y=parseFloat(/^WebGL\ ([0-9])/.exec(q)[1]),J=Y>=1):q.indexOf("OpenGL ES")!==-1&&(Y=parseFloat(/^OpenGL\ ES\ ([0-9])/.exec(q)[1]),J=Y>=2);var E=null,T={},U=new Fe,L=new Fe;function Q(D,te,ne){var we=new Uint8Array(4),se=e.createTexture();e.bindTexture(D,se),e.texParameteri(D,e.TEXTURE_MIN_FILTER,e.NEAREST),e.texParameteri(D,e.TEXTURE_MAG_FILTER,e.NEAREST);for(var Ee=0;Ee<ne;Ee++)e.texImage2D(te+Ee,0,e.RGBA,1,1,0,e.RGBA,e.UNSIGNED_BYTE,we);return se}var B={};B[e.TEXTURE_2D]=Q(e.TEXTURE_2D,e.TEXTURE_2D,1),B[e.TEXTURE_CUBE_MAP]=Q(e.TEXTURE_CUBE_MAP,e.TEXTURE_CUBE_MAP_POSITIVE_X,6),o.setClear(0,0,0,1),h.setClear(1),c.setClear(0),le(e.DEPTH_TEST),h.setFunc(ca),ze(!1),Ye(is),le(e.CULL_FACE),_e(Jr);function W(){for(var D=0,te=l.length;D<te;D++)l[D]=0}function j(D){pe(D,0)}function pe(D,te){if(l[D]=1,f[D]===0&&(e.enableVertexAttribArray(D),f[D]=1),d[D]!==te){var ne=i.isWebGL2?e:t.get("ANGLE_instanced_arrays");ne[i.isWebGL2?"vertexAttribDivisor":"vertexAttribDivisorANGLE"](D,te),d[D]=te}}function me(){for(var D=0,te=f.length;D!==te;++D)f[D]!==l[D]&&(e.disableVertexAttribArray(D),f[D]=0)}function le(D){p[D]!==!0&&(e.enable(D),p[D]=!0)}function H(D){p[D]!==!1&&(e.disable(D),p[D]=!1)}function he(){if(m===null&&(m=[],t.get("WEBGL_compressed_texture_pvrtc")||t.get("WEBGL_compressed_texture_s3tc")||t.get("WEBGL_compressed_texture_etc1")||t.get("WEBGL_compressed_texture_astc")))for(var D=e.getParameter(e.COMPRESSED_TEXTURE_FORMATS),te=0;te<D.length;te++)m.push(D[te]);return m}function Re(D){return v!==D?(e.useProgram(D),v=D,!0):!1}function _e(D,te,ne,we,se,Ee,Ie,Ce){if(D===Jr){g&&(H(e.BLEND),g=!1);return}if(g||(le(e.BLEND),g=!0),D!==Zs){if(D!==_||Ce!==A){if((w!==_r||R!==_r)&&(e.blendEquation(e.FUNC_ADD),w=_r,R=_r),Ce)switch(D){case br:e.blendFuncSeparate(e.ONE,e.ONE_MINUS_SRC_ALPHA,e.ONE,e.ONE_MINUS_SRC_ALPHA);break;case sa:e.blendFunc(e.ONE,e.ONE);break;case oa:e.blendFuncSeparate(e.ZERO,e.ZERO,e.ONE_MINUS_SRC_COLOR,e.ONE_MINUS_SRC_ALPHA);break;case ha:e.blendFuncSeparate(e.ZERO,e.SRC_COLOR,e.ZERO,e.SRC_ALPHA);break;default:console.error("THREE.WebGLState: Invalid blending: ",D);break}else switch(D){case br:e.blendFuncSeparate(e.SRC_ALPHA,e.ONE_MINUS_SRC_ALPHA,e.ONE,e.ONE_MINUS_SRC_ALPHA);break;case sa:e.blendFunc(e.SRC_ALPHA,e.ONE);break;case oa:e.blendFunc(e.ZERO,e.ONE_MINUS_SRC_COLOR);break;case ha:e.blendFunc(e.ZERO,e.SRC_COLOR);break;default:console.error("THREE.WebGLState: Invalid blending: ",D);break}y=null,S=null,I=null,C=null,_=D,A=Ce}return}se=se||te,Ee=Ee||ne,Ie=Ie||we,(te!==w||se!==R)&&(e.blendEquationSeparate(r.convert(te),r.convert(se)),w=te,R=se),(ne!==y||we!==S||Ee!==I||Ie!==C)&&(e.blendFuncSeparate(r.convert(ne),r.convert(we),r.convert(Ee),r.convert(Ie)),y=ne,S=we,I=Ee,C=Ie),_=D,A=null}function rt(D,te){D.side===Ni?H(e.CULL_FACE):le(e.CULL_FACE);var ne=D.side===st;te&&(ne=!ne),ze(ne),D.blending===br&&D.transparent===!1?_e(Jr):_e(D.blending,D.blendEquation,D.blendSrc,D.blendDst,D.blendEquationAlpha,D.blendSrcAlpha,D.blendDstAlpha,D.premultipliedAlpha),h.setFunc(D.depthFunc),h.setTest(D.depthTest),h.setMask(D.depthWrite),o.setMask(D.colorWrite),zt(D.polygonOffset,D.polygonOffsetFactor,D.polygonOffsetUnits)}function ze(D){O!==D&&(D?e.frontFace(e.CW):e.frontFace(e.CCW),O=D)}function Ye(D){D!==eh?(le(e.CULL_FACE),D!==F&&(D===is?e.cullFace(e.BACK):D===th?e.cullFace(e.FRONT):e.cullFace(e.FRONT_AND_BACK))):H(e.CULL_FACE),F=D}function Ke(D){D!==N&&(J&&e.lineWidth(D),N=D)}function zt(D,te,ne){D?(le(e.POLYGON_OFFSET_FILL),(V!==te||k!==ne)&&(e.polygonOffset(te,ne),V=te,k=ne)):H(e.POLYGON_OFFSET_FILL)}function Lt(D){D?le(e.SCISSOR_TEST):H(e.SCISSOR_TEST)}function We(D){D===void 0&&(D=e.TEXTURE0+G-1),E!==D&&(e.activeTexture(D),E=D)}function Ze(D,te){E===null&&We();var ne=T[E];ne===void 0&&(ne={type:void 0,texture:void 0},T[E]=ne),(ne.type!==D||ne.texture!==te)&&(e.bindTexture(D,te||B[D]),ne.type=D,ne.texture=te)}function $e(){try{e.compressedTexImage2D.apply(e,arguments)}catch(D){console.error("THREE.WebGLState:",D)}}function gr(){try{e.texImage2D.apply(e,arguments)}catch(D){console.error("THREE.WebGLState:",D)}}function ft(){try{e.texImage3D.apply(e,arguments)}catch(D){console.error("THREE.WebGLState:",D)}}function dt(D){U.equals(D)===!1&&(e.scissor(D.x,D.y,D.z,D.w),U.copy(D))}function Me(D){L.equals(D)===!1&&(e.viewport(D.x,D.y,D.z,D.w),L.copy(D))}function Ae(){for(var D=0;D<f.length;D++)f[D]===1&&(e.disableVertexAttribArray(D),f[D]=0);p={},m=null,E=null,T={},v=null,_=null,O=null,F=null,o.reset(),h.reset(),c.reset()}return{buffers:{color:o,depth:h,stencil:c},initAttributes:W,enableAttribute:j,enableAttributeAndDivisor:pe,disableUnusedAttributes:me,enable:le,disable:H,getCompressedTextureFormats:he,useProgram:Re,setBlending:_e,setMaterial:rt,setFlipSided:ze,setCullFace:Ye,setLineWidth:Ke,setPolygonOffset:zt,setScissorTest:Lt,activeTexture:We,bindTexture:Ze,compressedTexImage2D:$e,texImage2D:gr,texImage3D:ft,scissor:dt,viewport:Me,reset:Ae}}function Cf(e,t,r,i,n,a,s){var o={},h;function c(E,T,U,L){var Q=1;if((E.width>L||E.height>L)&&(Q=L/Math.max(E.width,E.height)),Q<1||T===!0)if(E instanceof HTMLImageElement||E instanceof HTMLCanvasElement||E instanceof ImageBitmap){h===void 0&&(h=document.createElementNS("http://www.w3.org/1999/xhtml","canvas"));var B=U?document.createElementNS("http://www.w3.org/1999/xhtml","canvas"):h,W=T?ge.floorPowerOfTwo:Math.floor;B.width=W(Q*E.width),B.height=W(Q*E.height);var j=B.getContext("2d");return j.drawImage(E,0,0,B.width,B.height),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+E.width+"x"+E.height+") to ("+B.width+"x"+B.height+")."),B}else return"data"in E&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+E.width+"x"+E.height+")."),E;return E}function u(E){return ge.isPowerOfTwo(E.width)&&ge.isPowerOfTwo(E.height)}function l(E){return n.isWebGL2?!1:E.wrapS!==Et||E.wrapT!==Et||E.minFilter!==et&&E.minFilter!==it}function f(E,T){return E.generateMipmaps&&T&&E.minFilter!==et&&E.minFilter!==it}function d(E,T,U,L){e.generateMipmap(E);var Q=i.get(T);Q.__maxMipLevel=Math.log(Math.max(U,L))*Math.LOG2E}function p(E,T){if(!n.isWebGL2)return E;var U=E;return E===e.RED&&(T===e.FLOAT&&(U=e.R32F),T===e.HALF_FLOAT&&(U=e.R16F),T===e.UNSIGNED_BYTE&&(U=e.R8)),E===e.RGB&&(T===e.FLOAT&&(U=e.RGB32F),T===e.HALF_FLOAT&&(U=e.RGB16F),T===e.UNSIGNED_BYTE&&(U=e.RGB8)),E===e.RGBA&&(T===e.FLOAT&&(U=e.RGBA32F),T===e.HALF_FLOAT&&(U=e.RGBA16F),T===e.UNSIGNED_BYTE&&(U=e.RGBA8)),U===e.R16F||U===e.R32F||U===e.RGBA16F||U===e.RGBA32F?t.get("EXT_color_buffer_float"):(U===e.RGB16F||U===e.RGB32F)&&console.warn("THREE.WebGLRenderer: Floating point textures with RGB format not supported. Please use RGBA instead."),U}function m(E){return E===et||E===qa||E===Ya?e.NEAREST:e.LINEAR}function v(E){var T=E.target;T.removeEventListener("dispose",v),_(T),T.isVideoTexture&&delete o[T.id],s.memory.textures--}function g(E){var T=E.target;T.removeEventListener("dispose",g),w(T),s.memory.textures--}function _(E){var T=i.get(E);if(E.image&&T.__image__webglTextureCube)e.deleteTexture(T.__image__webglTextureCube);else{if(T.__webglInit===void 0)return;e.deleteTexture(T.__webglTexture)}i.remove(E)}function w(E){var T=i.get(E),U=i.get(E.texture);if(E){if(U.__webglTexture!==void 0&&e.deleteTexture(U.__webglTexture),E.depthTexture&&E.depthTexture.dispose(),E.isWebGLRenderTargetCube)for(var L=0;L<6;L++)e.deleteFramebuffer(T.__webglFramebuffer[L]),T.__webglDepthbuffer&&e.deleteRenderbuffer(T.__webglDepthbuffer[L]);else e.deleteFramebuffer(T.__webglFramebuffer),T.__webglDepthbuffer&&e.deleteRenderbuffer(T.__webglDepthbuffer);i.remove(E.texture),i.remove(E)}}function y(E,T){var U=i.get(E);if(E.isVideoTexture&&q(E),E.version>0&&U.__version!==E.version){var L=E.image;if(L===void 0)console.warn("THREE.WebGLRenderer: Texture marked for update but image is undefined");else if(L.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{A(U,E,T);return}}r.activeTexture(e.TEXTURE0+T),r.bindTexture(e.TEXTURE_2D,U.__webglTexture)}function S(E,T){var U=i.get(E);if(E.version>0&&U.__version!==E.version){A(U,E,T);return}r.activeTexture(e.TEXTURE0+T),r.bindTexture(e.TEXTURE_3D,U.__webglTexture)}function R(E,T){var U=i.get(E);if(E.image.length===6)if(E.version>0&&U.__version!==E.version){U.__image__webglTextureCube||(E.addEventListener("dispose",v),U.__image__webglTextureCube=e.createTexture(),s.memory.textures++),r.activeTexture(e.TEXTURE0+T),r.bindTexture(e.TEXTURE_CUBE_MAP,U.__image__webglTextureCube),e.pixelStorei(e.UNPACK_FLIP_Y_WEBGL,E.flipY);for(var L=E&&E.isCompressedTexture,Q=E.image[0]&&E.image[0].isDataTexture,B=[],W=0;W<6;W++)!L&&!Q?B[W]=c(E.image[W],!1,!0,n.maxCubemapSize):B[W]=Q?E.image[W].image:E.image[W];var j=B[0],pe=u(j),me=a.convert(E.format),le=a.convert(E.type),H=p(me,le);C(e.TEXTURE_CUBE_MAP,E,pe);for(var W=0;W<6;W++)if(!L)Q?r.texImage2D(e.TEXTURE_CUBE_MAP_POSITIVE_X+W,0,H,B[W].width,B[W].height,0,me,le,B[W].data):r.texImage2D(e.TEXTURE_CUBE_MAP_POSITIVE_X+W,0,H,me,le,B[W]);else for(var he,Re=B[W].mipmaps,_e=0,rt=Re.length;_e<rt;_e++)he=Re[_e],E.format!==Wt&&E.format!==cr?r.getCompressedTextureFormats().indexOf(me)>-1?r.compressedTexImage2D(e.TEXTURE_CUBE_MAP_POSITIVE_X+W,_e,H,he.width,he.height,0,he.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):r.texImage2D(e.TEXTURE_CUBE_MAP_POSITIVE_X+W,_e,H,he.width,he.height,0,me,le,he.data);L?U.__maxMipLevel=Re.length-1:U.__maxMipLevel=0,f(E,pe)&&d(e.TEXTURE_CUBE_MAP,E,j.width,j.height),U.__version=E.version,E.onUpdate&&E.onUpdate(E)}else r.activeTexture(e.TEXTURE0+T),r.bindTexture(e.TEXTURE_CUBE_MAP,U.__image__webglTextureCube)}function I(E,T){r.activeTexture(e.TEXTURE0+T),r.bindTexture(e.TEXTURE_CUBE_MAP,i.get(E).__webglTexture)}function C(E,T,U){var L;if(U?(e.texParameteri(E,e.TEXTURE_WRAP_S,a.convert(T.wrapS)),e.texParameteri(E,e.TEXTURE_WRAP_T,a.convert(T.wrapT)),e.texParameteri(E,e.TEXTURE_MAG_FILTER,a.convert(T.magFilter)),e.texParameteri(E,e.TEXTURE_MIN_FILTER,a.convert(T.minFilter))):(e.texParameteri(E,e.TEXTURE_WRAP_S,e.CLAMP_TO_EDGE),e.texParameteri(E,e.TEXTURE_WRAP_T,e.CLAMP_TO_EDGE),(T.wrapS!==Et||T.wrapT!==Et)&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.wrapS and Texture.wrapT should be set to THREE.ClampToEdgeWrapping."),e.texParameteri(E,e.TEXTURE_MAG_FILTER,m(T.magFilter)),e.texParameteri(E,e.TEXTURE_MIN_FILTER,m(T.minFilter)),T.minFilter!==et&&T.minFilter!==it&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.minFilter should be set to THREE.NearestFilter or THREE.LinearFilter.")),L=t.get("EXT_texture_filter_anisotropic"),L){if(T.type===$r&&t.get("OES_texture_float_linear")===null||T.type===Za&&(n.isWebGL2||t.get("OES_texture_half_float_linear"))===null)return;(T.anisotropy>1||i.get(T).__currentAnisotropy)&&(e.texParameterf(E,L.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(T.anisotropy,n.getMaxAnisotropy())),i.get(T).__currentAnisotropy=T.anisotropy)}}function A(E,T,U){var L;T.isDataTexture3D?L=e.TEXTURE_3D:L=e.TEXTURE_2D,E.__webglInit===void 0&&(E.__webglInit=!0,T.addEventListener("dispose",v),E.__webglTexture=e.createTexture(),s.memory.textures++),r.activeTexture(e.TEXTURE0+U),r.bindTexture(L,E.__webglTexture),e.pixelStorei(e.UNPACK_FLIP_Y_WEBGL,T.flipY),e.pixelStorei(e.UNPACK_PREMULTIPLY_ALPHA_WEBGL,T.premultiplyAlpha),e.pixelStorei(e.UNPACK_ALIGNMENT,T.unpackAlignment);var Q=l(T)&&u(T.image)===!1,B=c(T.image,Q,!1,n.maxTextureSize),W=u(B),j=a.convert(T.format),pe=a.convert(T.type),me=p(j,pe);C(L,T,W);var le,H=T.mipmaps;if(T.isDepthTexture){if(me=e.DEPTH_COMPONENT,T.type===$r){if(!n.isWebGL2)throw new Error("Float Depth Texture only supported in WebGL2.0");me=e.DEPTH_COMPONENT32F}else n.isWebGL2&&(me=e.DEPTH_COMPONENT16);T.format===Mr&&me===e.DEPTH_COMPONENT&&T.type!==Zi&&T.type!==ro&&(console.warn("THREE.WebGLRenderer: Use UnsignedShortType or UnsignedIntType for DepthFormat DepthTexture."),T.type=Zi,pe=a.convert(T.type)),T.format===ei&&(me=e.DEPTH_STENCIL,T.type!==Ji&&(console.warn("THREE.WebGLRenderer: Use UnsignedInt248Type for DepthStencilFormat DepthTexture."),T.type=Ji,pe=a.convert(T.type))),r.texImage2D(e.TEXTURE_2D,0,me,B.width,B.height,0,j,pe,null)}else if(T.isDataTexture){if(H.length>0&&W){for(var he=0,Re=H.length;he<Re;he++)le=H[he],r.texImage2D(e.TEXTURE_2D,he,me,le.width,le.height,0,j,pe,le.data);T.generateMipmaps=!1,E.__maxMipLevel=H.length-1}else r.texImage2D(e.TEXTURE_2D,0,me,B.width,B.height,0,j,pe,B.data),E.__maxMipLevel=0;T.isCfxTexture&&(e.texParameterf(e.TEXTURE_2D,e.TEXTURE_WRAP_T,e.CLAMP_TO_EDGE),e.texParameterf(e.TEXTURE_2D,e.TEXTURE_WRAP_T,e.MIRRORED_REPEAT),e.texParameterf(e.TEXTURE_2D,e.TEXTURE_WRAP_T,e.REPEAT))}else if(T.isCompressedTexture){for(var he=0,Re=H.length;he<Re;he++)le=H[he],T.format!==Wt&&T.format!==cr?r.getCompressedTextureFormats().indexOf(j)>-1?r.compressedTexImage2D(e.TEXTURE_2D,he,me,le.width,le.height,0,le.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):r.texImage2D(e.TEXTURE_2D,he,me,le.width,le.height,0,j,pe,le.data);E.__maxMipLevel=H.length-1}else if(T.isDataTexture3D)r.texImage3D(e.TEXTURE_3D,0,me,B.width,B.height,B.depth,0,j,pe,B.data),E.__maxMipLevel=0;else if(H.length>0&&W){for(var he=0,Re=H.length;he<Re;he++)le=H[he],r.texImage2D(e.TEXTURE_2D,he,me,j,pe,le);T.generateMipmaps=!1,E.__maxMipLevel=H.length-1}else r.texImage2D(e.TEXTURE_2D,0,me,j,pe,B),E.__maxMipLevel=0;f(T,W)&&d(e.TEXTURE_2D,T,B.width,B.height),E.__version=T.version,T.onUpdate&&T.onUpdate(T)}function O(E,T,U,L){var Q=a.convert(T.texture.format),B=a.convert(T.texture.type),W=p(Q,B);r.texImage2D(L,0,W,T.width,T.height,0,Q,B,null),e.bindFramebuffer(e.FRAMEBUFFER,E),e.framebufferTexture2D(e.FRAMEBUFFER,U,L,i.get(T.texture).__webglTexture,0),e.bindFramebuffer(e.FRAMEBUFFER,null)}function F(E,T,U){if(e.bindRenderbuffer(e.RENDERBUFFER,E),T.depthBuffer&&!T.stencilBuffer){if(U){var L=Y(T);e.renderbufferStorageMultisample(e.RENDERBUFFER,L,e.DEPTH_COMPONENT16,T.width,T.height)}else e.renderbufferStorage(e.RENDERBUFFER,e.DEPTH_COMPONENT16,T.width,T.height);e.framebufferRenderbuffer(e.FRAMEBUFFER,e.DEPTH_ATTACHMENT,e.RENDERBUFFER,E)}else if(T.depthBuffer&&T.stencilBuffer){if(U){var L=Y(T);e.renderbufferStorageMultisample(e.RENDERBUFFER,L,e.DEPTH_STENCIL,T.width,T.height)}else e.renderbufferStorage(e.RENDERBUFFER,e.DEPTH_STENCIL,T.width,T.height);e.framebufferRenderbuffer(e.FRAMEBUFFER,e.DEPTH_STENCIL_ATTACHMENT,e.RENDERBUFFER,E)}else{var Q=a.convert(T.texture.format),B=a.convert(T.texture.type),W=p(Q,B);if(U){var L=Y(T);e.renderbufferStorageMultisample(e.RENDERBUFFER,L,W,T.width,T.height)}else e.renderbufferStorage(e.RENDERBUFFER,W,T.width,T.height)}e.bindRenderbuffer(e.RENDERBUFFER,null)}function N(E,T){var U=T&&T.isWebGLRenderTargetCube;if(U)throw new Error("Depth Texture with cube render targets is not supported");if(e.bindFramebuffer(e.FRAMEBUFFER,E),!(T.depthTexture&&T.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");(!i.get(T.depthTexture).__webglTexture||T.depthTexture.image.width!==T.width||T.depthTexture.image.height!==T.height)&&(T.depthTexture.image.width=T.width,T.depthTexture.image.height=T.height,T.depthTexture.needsUpdate=!0),y(T.depthTexture,0);var L=i.get(T.depthTexture).__webglTexture;if(T.depthTexture.format===Mr)e.framebufferTexture2D(e.FRAMEBUFFER,e.DEPTH_ATTACHMENT,e.TEXTURE_2D,L,0);else if(T.depthTexture.format===ei)e.framebufferTexture2D(e.FRAMEBUFFER,e.DEPTH_STENCIL_ATTACHMENT,e.TEXTURE_2D,L,0);else throw new Error("Unknown depthTexture format")}function V(E){var T=i.get(E),U=E.isWebGLRenderTargetCube===!0;if(E.depthTexture){if(U)throw new Error("target.depthTexture not supported in Cube render targets");N(T.__webglFramebuffer,E)}else if(U){T.__webglDepthbuffer=[];for(var L=0;L<6;L++)e.bindFramebuffer(e.FRAMEBUFFER,T.__webglFramebuffer[L]),T.__webglDepthbuffer[L]=e.createRenderbuffer(),F(T.__webglDepthbuffer[L],E)}else e.bindFramebuffer(e.FRAMEBUFFER,T.__webglFramebuffer),T.__webglDepthbuffer=e.createRenderbuffer(),F(T.__webglDepthbuffer,E);e.bindFramebuffer(e.FRAMEBUFFER,null)}function k(E){var T=i.get(E),U=i.get(E.texture);E.addEventListener("dispose",g),U.__webglTexture=e.createTexture(),s.memory.textures++;var L=E.isWebGLRenderTargetCube===!0,Q=E.isWebGLMultisampleRenderTarget===!0,B=u(E);if(L){T.__webglFramebuffer=[];for(var W=0;W<6;W++)T.__webglFramebuffer[W]=e.createFramebuffer()}else if(T.__webglFramebuffer=e.createFramebuffer(),Q)if(n.isWebGL2){T.__webglMultisampledFramebuffer=e.createFramebuffer(),T.__webglColorRenderbuffer=e.createRenderbuffer(),e.bindRenderbuffer(e.RENDERBUFFER,T.__webglColorRenderbuffer);var j=a.convert(E.texture.format),pe=a.convert(E.texture.type),me=p(j,pe),le=Y(E);e.renderbufferStorageMultisample(e.RENDERBUFFER,le,me,E.width,E.height),e.bindFramebuffer(e.FRAMEBUFFER,T.__webglMultisampledFramebuffer),e.framebufferRenderbuffer(e.FRAMEBUFFER,e.COLOR_ATTACHMENT0,e.RENDERBUFFER,T.__webglColorRenderbuffer),e.bindRenderbuffer(e.RENDERBUFFER,null),E.depthBuffer&&(T.__webglDepthRenderbuffer=e.createRenderbuffer(),F(T.__webglDepthRenderbuffer,E,!0)),e.bindFramebuffer(e.FRAMEBUFFER,null)}else console.warn("THREE.WebGLRenderer: WebGLMultisampleRenderTarget can only be used with WebGL2.");if(L){r.bindTexture(e.TEXTURE_CUBE_MAP,U.__webglTexture),C(e.TEXTURE_CUBE_MAP,E.texture,B);for(var W=0;W<6;W++)O(T.__webglFramebuffer[W],E,e.COLOR_ATTACHMENT0,e.TEXTURE_CUBE_MAP_POSITIVE_X+W);f(E.texture,B)&&d(e.TEXTURE_CUBE_MAP,E.texture,E.width,E.height),r.bindTexture(e.TEXTURE_CUBE_MAP,null)}else r.bindTexture(e.TEXTURE_2D,U.__webglTexture),C(e.TEXTURE_2D,E.texture,B),O(T.__webglFramebuffer,E,e.COLOR_ATTACHMENT0,e.TEXTURE_2D),f(E.texture,B)&&d(e.TEXTURE_2D,E.texture,E.width,E.height),r.bindTexture(e.TEXTURE_2D,null);E.depthBuffer&&V(E)}function G(E){var T=E.texture,U=u(E);if(f(T,U)){var L=E.isWebGLRenderTargetCube?e.TEXTURE_CUBE_MAP:e.TEXTURE_2D,Q=i.get(T).__webglTexture;r.bindTexture(L,Q),d(L,T,E.width,E.height),r.bindTexture(L,null)}}function J(E){if(E.isWebGLMultisampleRenderTarget)if(n.isWebGL2){var T=i.get(E);e.bindFramebuffer(e.READ_FRAMEBUFFER,T.__webglMultisampledFramebuffer),e.bindFramebuffer(e.DRAW_FRAMEBUFFER,T.__webglFramebuffer);var U=E.width,L=E.height,Q=e.COLOR_BUFFER_BIT;E.depthBuffer&&(Q|=e.DEPTH_BUFFER_BIT),E.stencilBuffer&&(Q|=e.STENCIL_BUFFER_BIT),e.blitFramebuffer(0,0,U,L,0,0,U,L,Q,e.NEAREST)}else console.warn("THREE.WebGLRenderer: WebGLMultisampleRenderTarget can only be used with WebGL2.")}function Y(E){return n.isWebGL2&&E.isWebGLMultisampleRenderTarget?Math.min(n.maxSamples,E.samples):0}function q(E){var T=E.id,U=s.render.frame;o[T]!==U&&(o[T]=U,E.update())}this.setTexture2D=y,this.setTexture3D=S,this.setTextureCube=R,this.setTextureCubeDynamic=I,this.setupRenderTarget=k,this.updateRenderTargetMipmap=G,this.updateMultisampleRenderTarget=J}function If(e,t,r){function i(n){var a;if(n===Qt)return e.REPEAT;if(n===Et)return e.CLAMP_TO_EDGE;if(n===Er)return e.MIRRORED_REPEAT;if(n===et)return e.NEAREST;if(n===qa)return e.NEAREST_MIPMAP_NEAREST;if(n===Ya)return e.NEAREST_MIPMAP_LINEAR;if(n===it)return e.LINEAR;if(n===to)return e.LINEAR_MIPMAP_NEAREST;if(n===Vn)return e.LINEAR_MIPMAP_LINEAR;if(n===kn)return e.UNSIGNED_BYTE;if(n===Ph)return e.UNSIGNED_SHORT_4_4_4_4;if(n===Ch)return e.UNSIGNED_SHORT_5_5_5_1;if(n===Ih)return e.UNSIGNED_SHORT_5_6_5;if(n===Ah)return e.BYTE;if(n===Lh)return e.SHORT;if(n===Zi)return e.UNSIGNED_SHORT;if(n===Rh)return e.INT;if(n===ro)return e.UNSIGNED_INT;if(n===$r)return e.FLOAT;if(n===Za){if(r.isWebGL2)return e.HALF_FLOAT;if(a=t.get("OES_texture_half_float"),a!==null)return a.HALF_FLOAT_OES}if(n===Dh)return e.ALPHA;if(n===cr)return e.RGB;if(n===Wt)return e.RGBA;if(n===Oh)return e.LUMINANCE;if(n===Fh)return e.LUMINANCE_ALPHA;if(n===Mr)return e.DEPTH_COMPONENT;if(n===ei)return e.DEPTH_STENCIL;if(n===Uh)return e.RED;if(n===_r)return e.FUNC_ADD;if(n===ih)return e.FUNC_SUBTRACT;if(n===nh)return e.FUNC_REVERSE_SUBTRACT;if(n===ah)return e.ZERO;if(n===sh)return e.ONE;if(n===oh)return e.SRC_COLOR;if(n===hh)return e.ONE_MINUS_SRC_COLOR;if(n===Js)return e.SRC_ALPHA;if(n===Qs)return e.ONE_MINUS_SRC_ALPHA;if(n===ch)return e.DST_ALPHA;if(n===uh)return e.ONE_MINUS_DST_ALPHA;if(n===lh)return e.DST_COLOR;if(n===fh)return e.ONE_MINUS_DST_COLOR;if(n===dh)return e.SRC_ALPHA_SATURATE;if((n===ns||n===as||n===ss||n===os)&&(a=t.get("WEBGL_compressed_texture_s3tc"),a!==null)){if(n===ns)return a.COMPRESSED_RGB_S3TC_DXT1_EXT;if(n===as)return a.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(n===ss)return a.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(n===os)return a.COMPRESSED_RGBA_S3TC_DXT5_EXT}if((n===hs||n===cs||n===us||n===ls)&&(a=t.get("WEBGL_compressed_texture_pvrtc"),a!==null)){if(n===hs)return a.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(n===cs)return a.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(n===us)return a.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(n===ls)return a.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}if(n===Bh&&(a=t.get("WEBGL_compressed_texture_etc1"),a!==null))return a.COMPRESSED_RGB_ETC1_WEBGL;if((n===Nh||n===Gh||n===zh||n===Hh||n===Vh||n===kh||n===Wh||n===Xh||n===jh||n===qh||n===Yh||n===Zh||n===Jh||n===Qh)&&(a=t.get("WEBGL_compressed_texture_astc"),a!==null))return n;if(n===Jn||n===Qn){if(r.isWebGL2){if(n===Jn)return e.MIN;if(n===Qn)return e.MAX}if(a=t.get("EXT_blend_minmax"),a!==null){if(n===Jn)return a.MIN_EXT;if(n===Qn)return a.MAX_EXT}}if(n===Ji){if(r.isWebGL2)return e.UNSIGNED_INT_24_8;if(a=t.get("WEBGL_depth_texture"),a!==null)return a.UNSIGNED_INT_24_8_WEBGL}return 0}return{convert:i}}function si(){K.call(this),this.type="Group"}si.prototype=Object.assign(Object.create(K.prototype),{constructor:si,isGroup:!0});function Xt(){K.call(this),this.type="Camera",this.matrixWorldInverse=new fe,this.projectionMatrix=new fe,this.projectionMatrixInverse=new fe}Xt.prototype=Object.assign(Object.create(K.prototype),{constructor:Xt,isCamera:!0,copy:function(e,t){return K.prototype.copy.call(this,e,t),this.matrixWorldInverse.copy(e.matrixWorldInverse),this.projectionMatrix.copy(e.projectionMatrix),this.projectionMatrixInverse.copy(e.projectionMatrixInverse),this},getWorldDirection:function(e){e===void 0&&(console.warn("THREE.Camera: .getWorldDirection() target is now required"),e=new b),this.updateMatrixWorld(!0);var t=this.matrixWorld.elements;return e.set(-t[8],-t[9],-t[10]).normalize()},updateMatrixWorld:function(e){K.prototype.updateMatrixWorld.call(this,e),this.matrixWorldInverse.getInverse(this.matrixWorld)},clone:function(){return new this.constructor().copy(this)}});function je(e,t,r,i){Xt.call(this),this.type="PerspectiveCamera",this.fov=e!==void 0?e:50,this.zoom=1,this.near=r!==void 0?r:.1,this.far=i!==void 0?i:2e3,this.focus=10,this.aspect=t!==void 0?t:1,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}je.prototype=Object.assign(Object.create(Xt.prototype),{constructor:je,isPerspectiveCamera:!0,copy:function(e,t){return Xt.prototype.copy.call(this,e,t),this.fov=e.fov,this.zoom=e.zoom,this.near=e.near,this.far=e.far,this.focus=e.focus,this.aspect=e.aspect,this.view=e.view===null?null:Object.assign({},e.view),this.filmGauge=e.filmGauge,this.filmOffset=e.filmOffset,this},setFocalLength:function(e){var t=.5*this.getFilmHeight()/e;this.fov=ge.RAD2DEG*2*Math.atan(t),this.updateProjectionMatrix()},getFocalLength:function(){var e=Math.tan(ge.DEG2RAD*.5*this.fov);return .5*this.getFilmHeight()/e},getEffectiveFOV:function(){return ge.RAD2DEG*2*Math.atan(Math.tan(ge.DEG2RAD*.5*this.fov)/this.zoom)},getFilmWidth:function(){return this.filmGauge*Math.min(this.aspect,1)},getFilmHeight:function(){return this.filmGauge/Math.max(this.aspect,1)},setViewOffset:function(e,t,r,i,n,a){this.aspect=e/t,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=r,this.view.offsetY=i,this.view.width=n,this.view.height=a,this.updateProjectionMatrix()},clearViewOffset:function(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()},updateProjectionMatrix:function(){var e=this.near,t=e*Math.tan(ge.DEG2RAD*.5*this.fov)/this.zoom,r=2*t,i=this.aspect*r,n=-.5*i,a=this.view;if(this.view!==null&&this.view.enabled){var s=a.fullWidth,o=a.fullHeight;n+=a.offsetX*i/s,t-=a.offsetY*r/o,i*=a.width/s,r*=a.height/o}var h=this.filmOffset;h!==0&&(n+=e*h/this.getFilmWidth()),this.projectionMatrix.makePerspective(n,n+i,t,t-r,e,this.far),this.projectionMatrixInverse.getInverse(this.projectionMatrix)},toJSON:function(e){var t=K.prototype.toJSON.call(this,e);return t.object.fov=this.fov,t.object.zoom=this.zoom,t.object.near=this.near,t.object.far=this.far,t.object.focus=this.focus,t.object.aspect=this.aspect,this.view!==null&&(t.object.view=Object.assign({},this.view)),t.object.filmGauge=this.filmGauge,t.object.filmOffset=this.filmOffset,t}});function nn(e){je.call(this),this.cameras=e||[]}nn.prototype=Object.assign(Object.create(je.prototype),{constructor:nn,isArrayCamera:!0});var Ts=new b,Ss=new b;function _o(e,t,r){Ts.setFromMatrixPosition(t.matrixWorld),Ss.setFromMatrixPosition(r.matrixWorld);var i=Ts.distanceTo(Ss),n=t.projectionMatrix.elements,a=r.projectionMatrix.elements,s=n[14]/(n[10]-1),o=n[14]/(n[10]+1),h=(n[9]+1)/n[5],c=(n[9]-1)/n[5],u=(n[8]-1)/n[0],l=(a[8]+1)/a[0],f=s*u,d=s*l,p=i/(-u+l),m=p*-u;t.matrixWorld.decompose(e.position,e.quaternion,e.scale),e.translateX(m),e.translateZ(p),e.matrixWorld.compose(e.position,e.quaternion,e.scale),e.matrixWorldInverse.getInverse(e.matrixWorld);var v=s+p,g=o+p,_=f-m,w=d+(i-m),y=h*o/g*v,S=c*o/g*v;e.projectionMatrix.makePerspective(_,w,y,S,v,g)}function wo(e){var t=this,r=null,i=null,n=null,a=[],s=new fe,o=new fe,h=1,c="stage";typeof window<"u"&&"VRFrameData"in window&&(i=new window.VRFrameData,window.addEventListener("vrdisplaypresentchange",w,!1));var u=new fe,l=new Qe,f=new b,d=new je;d.bounds=new Fe(0,0,.5,1),d.layers.enable(1);var p=new je;p.bounds=new Fe(.5,0,.5,1),p.layers.enable(2);var m=new nn([d,p]);m.layers.enable(1),m.layers.enable(2);function v(){return r!==null&&r.isPresenting===!0}var g,_;function w(){if(v()){var C=r.getEyeParameters("left"),A=C.renderWidth*h,O=C.renderHeight*h;_=e.getPixelRatio(),g=e.getSize(),e.setDrawingBufferSize(A*2,O,1),I.start()}else t.enabled&&e.setDrawingBufferSize(g.width,g.height,_),I.stop()}var y=[];function S(C){for(var A=navigator.getGamepads&&navigator.getGamepads(),O=0,F=0,N=A.length;O<N;O++){var V=A[O];if(V&&(V.id==="Daydream Controller"||V.id==="Gear VR Controller"||V.id==="Oculus Go Controller"||V.id==="OpenVR Gamepad"||V.id.startsWith("Oculus Touch")||V.id.startsWith("Spatial Controller"))){if(F===C)return V;F++}}}function R(){for(var C=0;C<a.length;C++){var A=a[C],O=S(C);if(O!==void 0&&O.pose!==void 0){if(O.pose===null)return;var F=O.pose;F.hasPosition===!1&&A.position.set(.2,-.6,-.05),F.position!==null&&A.position.fromArray(F.position),F.orientation!==null&&A.quaternion.fromArray(F.orientation),A.matrix.compose(A.position,A.quaternion,A.scale),A.matrix.premultiply(s),A.matrix.decompose(A.position,A.quaternion,A.scale),A.matrixWorldNeedsUpdate=!0,A.visible=!0;var N=O.id==="Daydream Controller"?0:1;y[C]!==O.buttons[N].pressed&&(y[C]=O.buttons[N].pressed,y[C]===!0?A.dispatchEvent({type:"selectstart"}):(A.dispatchEvent({type:"selectend"}),A.dispatchEvent({type:"select"})))}else A.visible=!1}}this.enabled=!1,this.getController=function(C){var A=a[C];return A===void 0&&(A=new si,A.matrixAutoUpdate=!1,A.visible=!1,a[C]=A),A},this.getDevice=function(){return r},this.setDevice=function(C){C!==void 0&&(r=C),I.setContext(C)},this.setFramebufferScaleFactor=function(C){h=C},this.setFrameOfReferenceType=function(C){c=C},this.setPoseTarget=function(C){C!==void 0&&(n=C)},this.getCamera=function(C){var A=c==="stage"?1.6:0;if(r===null)return C.position.set(0,A,0),C;if(r.depthNear=C.near,r.depthFar=C.far,r.getFrameData(i),c==="stage"){var O=r.stageParameters;O?s.fromArray(O.sittingToStandingTransform):s.makeTranslation(0,A,0)}var F=i.pose,N=n!==null?n:C;if(N.matrix.copy(s),N.matrix.decompose(N.position,N.quaternion,N.scale),F.orientation!==null&&(l.fromArray(F.orientation),N.quaternion.multiply(l)),F.position!==null&&(l.setFromRotationMatrix(s),f.fromArray(F.position),f.applyQuaternion(l),N.position.add(f)),N.updateMatrixWorld(),r.isPresenting===!1)return C;d.near=C.near,p.near=C.near,d.far=C.far,p.far=C.far,d.matrixWorldInverse.fromArray(i.leftViewMatrix),p.matrixWorldInverse.fromArray(i.rightViewMatrix),o.getInverse(s),c==="stage"&&(d.matrixWorldInverse.multiply(o),p.matrixWorldInverse.multiply(o));var V=N.parent;V!==null&&(u.getInverse(V.matrixWorld),d.matrixWorldInverse.multiply(u),p.matrixWorldInverse.multiply(u)),d.matrixWorld.getInverse(d.matrixWorldInverse),p.matrixWorld.getInverse(p.matrixWorldInverse),d.projectionMatrix.fromArray(i.leftProjectionMatrix),p.projectionMatrix.fromArray(i.rightProjectionMatrix),_o(m,d,p);var k=r.getLayers();if(k.length){var G=k[0];G.leftBounds!==null&&G.leftBounds.length===4&&d.bounds.fromArray(G.leftBounds),G.rightBounds!==null&&G.rightBounds.length===4&&p.bounds.fromArray(G.rightBounds)}return R(),m},this.getStandingMatrix=function(){return s},this.isPresenting=v;var I=new Qa;this.setAnimationLoop=function(C){I.setAnimationLoop(C)},this.submitFrame=function(){v()&&r.submitFrame()},this.dispose=function(){typeof window<"u"&&window.removeEventListener("vrdisplaypresentchange",w)}}function Df(e){var t=e.context,r=null,i=null,n=1,a=null,s="stage",o=null,h=[],c=[];function u(){return i!==null&&a!==null}var l=new je;l.layers.enable(1),l.viewport=new Fe;var f=new je;f.layers.enable(2),f.viewport=new Fe;var d=new nn([l,f]);d.layers.enable(1),d.layers.enable(2),this.enabled=!1,this.getController=function(y){var S=h[y];return S===void 0&&(S=new si,S.matrixAutoUpdate=!1,S.visible=!1,h[y]=S),S},this.getDevice=function(){return r},this.setDevice=function(y){y!==void 0&&(r=y),y instanceof XRDevice&&t.setCompatibleXRDevice(y)};function p(y){var S=h[c.indexOf(y.inputSource)];S&&S.dispatchEvent({type:y.type})}function m(){e.setFramebuffer(null),w.stop()}this.setFramebufferScaleFactor=function(y){n=y},this.setFrameOfReferenceType=function(y){s=y},this.setSession=function(y){i=y,i!==null&&(i.addEventListener("select",p),i.addEventListener("selectstart",p),i.addEventListener("selectend",p),i.addEventListener("end",m),i.baseLayer=new XRWebGLLayer(i,t,{framebufferScaleFactor:n}),i.requestFrameOfReference(s).then(function(S){a=S,e.setFramebuffer(i.baseLayer.framebuffer),w.setContext(i),w.start()}),c=i.getInputSources(),i.addEventListener("inputsourceschange",function(){c=i.getInputSources();for(var S=0;S<h.length;S++){var R=h[S];R.userData.inputSource=c[S]}}))};function v(y,S){S===null?y.matrixWorld.copy(y.matrix):y.matrixWorld.multiplyMatrices(S.matrixWorld,y.matrix),y.matrixWorldInverse.getInverse(y.matrixWorld)}this.getCamera=function(y){if(u()){var S=y.parent,R=d.cameras;v(d,S);for(var I=0;I<R.length;I++)v(R[I],S);y.matrixWorld.copy(d.matrixWorld);for(var C=y.children,I=0,A=C.length;I<A;I++)C[I].updateMatrixWorld(!0);return _o(d,l,f),d}return y},this.isPresenting=u;var g=null;function _(y,S){if(o=S.getDevicePose(a),o!==null)for(var R=i.baseLayer,I=S.views,C=0;C<I.length;C++){var A=I[C],O=R.getViewport(A),F=o.getViewMatrix(A),N=d.cameras[C];N.matrix.fromArray(F).getInverse(N.matrix),N.projectionMatrix.fromArray(A.projectionMatrix),N.viewport.set(O.x,O.y,O.width,O.height),C===0&&d.matrix.copy(N.matrix)}for(var C=0;C<h.length;C++){var V=h[C],k=c[C];if(k){var G=S.getInputPose(k,a);if(G!==null){"targetRay"in G?V.matrix.elements=G.targetRay.transformMatrix:"pointerMatrix"in G&&(V.matrix.elements=G.pointerMatrix),V.matrix.decompose(V.position,V.rotation,V.scale),V.visible=!0;continue}}V.visible=!1}g&&g(y)}var w=new Qa;w.setAnimationLoop(_),this.setAnimationLoop=function(y){g=y},this.dispose=function(){},this.getStandingMatrix=function(){return console.warn("THREE.WebXRManager: getStandingMatrix() is no longer needed."),new THREE.Matrix4},this.submitFrame=function(){}}function Ka(e){e=e||{};var t=e.canvas!==void 0?e.canvas:document.createElementNS("http://www.w3.org/1999/xhtml","canvas"),r=e.context!==void 0?e.context:null,i=e.alpha!==void 0?e.alpha:!1,n=e.depth!==void 0?e.depth:!0,a=e.stencil!==void 0?e.stencil:!0,s=e.antialias!==void 0?e.antialias:!1,o=e.premultipliedAlpha!==void 0?e.premultipliedAlpha:!0,h=e.preserveDrawingBuffer!==void 0?e.preserveDrawingBuffer:!1,c=e.powerPreference!==void 0?e.powerPreference:"default",u=null,l=null;this.domElement=t,this.context=null,this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this.gammaFactor=2,this.gammaInput=!1,this.gammaOutput=!1,this.physicallyCorrectLights=!1,this.toneMapping=Ks,this.toneMappingExposure=1,this.toneMappingWhitePoint=1,this.maxMorphTargets=8,this.maxMorphNormals=4;var f=this,d=!1,p=null,m=null,v=null,g=-1,_={geometry:null,program:null,wireframe:!1},w=null,y=null,S=new Fe,R=new Fe,I=null,C=0,A=t.width,O=t.height,F=1,N=new Fe(0,0,A,O),V=new Fe(0,0,A,O),k=!1,G=new Ja,J=new Il,Y=!1,q=!1,E=new fe,T=new b;function U(){return m===null?F:1}var L;try{var Q={alpha:i,depth:n,stencil:a,antialias:s,premultipliedAlpha:o,preserveDrawingBuffer:h,powerPreference:c};if(t.addEventListener("webglcontextlost",ft,!1),t.addEventListener("webglcontextrestored",dt,!1),L=r||t.getContext("webgl",Q)||t.getContext("experimental-webgl",Q),L===null)throw t.getContext("webgl")!==null?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.");L.getShaderPrecisionFormat===void 0&&(L.getShaderPrecisionFormat=function(){return{rangeMin:1,rangeMax:1,precision:1}})}catch(x){console.error("THREE.WebGLRenderer: "+x.message)}var B,W,j,pe,me,le,H,he,Re,_e,rt,ze,Ye,Ke,zt,Lt,We;function Ze(){B=new Dl(L),W=new Cl(L,B,e),W.isWebGL2||(B.get("WEBGL_depth_texture"),B.get("OES_texture_float"),B.get("OES_texture_half_float"),B.get("OES_texture_half_float_linear"),B.get("OES_standard_derivatives"),B.get("OES_element_index_uint"),B.get("ANGLE_instanced_arrays")),B.get("OES_texture_float_linear"),We=new If(L,B,W),j=new Pf(L,B,We,W),j.scissor(R.copy(V).multiplyScalar(F)),j.viewport(S.copy(N).multiplyScalar(F)),pe=new Ul(L),me=new bf,le=new Cf(L,B,j,me,W,We,pe),H=new El(L),he=new Ol(L,H,pe),Re=new Gl(he,pe),Ke=new Nl(L),_e=new wf(f,B,W),rt=new Tf,ze=new Rf,Ye=new Rl(f,j,Re,o),zt=new Pl(L,B,pe,W),Lt=new Fl(L,B,pe,W),pe.programs=_e.programs,f.context=L,f.capabilities=W,f.extensions=B,f.properties=me,f.renderLists=rt,f.state=j,f.info=pe}Ze();var $e=null;typeof navigator<"u"&&($e="xr"in navigator?new Df(f):new wo(f)),this.vr=$e;var gr=new xo(f,Re,W.maxTextureSize);this.shadowMap=gr,this.getContext=function(){return L},this.getContextAttributes=function(){return L.getContextAttributes()},this.forceContextLoss=function(){var x=B.get("WEBGL_lose_context");x&&x.loseContext()},this.forceContextRestore=function(){var x=B.get("WEBGL_lose_context");x&&x.restoreContext()},this.getPixelRatio=function(){return F},this.setPixelRatio=function(x){x!==void 0&&(F=x,this.setSize(A,O,!1))},this.getSize=function(){return{width:A,height:O}},this.setSize=function(x,M,P){if($e.isPresenting()){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}A=x,O=M,t.width=x*F,t.height=M*F,P!==!1&&(t.style.width=x+"px",t.style.height=M+"px"),this.setViewport(0,0,x,M)},this.getDrawingBufferSize=function(){return{width:A*F,height:O*F}},this.setDrawingBufferSize=function(x,M,P){A=x,O=M,F=P,t.width=x*P,t.height=M*P,this.setViewport(0,0,x,M)},this.getCurrentViewport=function(){return S},this.setViewport=function(x,M,P,X){N.set(x,O-M-X,P,X),j.viewport(S.copy(N).multiplyScalar(F))},this.setScissor=function(x,M,P,X){V.set(x,O-M-X,P,X),j.scissor(R.copy(V).multiplyScalar(F))},this.setScissorTest=function(x){j.setScissorTest(k=x)},this.getClearColor=function(){return Ye.getClearColor()},this.setClearColor=function(){Ye.setClearColor.apply(Ye,arguments)},this.getClearAlpha=function(){return Ye.getClearAlpha()},this.setClearAlpha=function(){Ye.setClearAlpha.apply(Ye,arguments)},this.clear=function(x,M,P){var X=0;(x===void 0||x)&&(X|=L.COLOR_BUFFER_BIT),(M===void 0||M)&&(X|=L.DEPTH_BUFFER_BIT),(P===void 0||P)&&(X|=L.STENCIL_BUFFER_BIT),L.clear(X)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){t.removeEventListener("webglcontextlost",ft,!1),t.removeEventListener("webglcontextrestored",dt,!1),rt.dispose(),ze.dispose(),me.dispose(),Re.dispose(),$e.dispose(),Ee.stop()};function ft(x){x.preventDefault(),d=!0}function dt(){d=!1,Ze()}function Me(x){var M=x.target;M.removeEventListener("dispose",Me),Ae(M)}function Ae(x){D(x),me.remove(x)}function D(x){var M=me.get(x).program;x.program=void 0,M!==void 0&&_e.releaseProgram(M)}function te(x,M){x.render(function(P){f.renderBufferImmediate(P,M)})}this.renderBufferImmediate=function(x,M){j.initAttributes();var P=me.get(x);x.hasPositions&&!P.position&&(P.position=L.createBuffer()),x.hasNormals&&!P.normal&&(P.normal=L.createBuffer()),x.hasUvs&&!P.uv&&(P.uv=L.createBuffer()),x.hasColors&&!P.color&&(P.color=L.createBuffer());var X=M.getAttributes();x.hasPositions&&(L.bindBuffer(L.ARRAY_BUFFER,P.position),L.bufferData(L.ARRAY_BUFFER,x.positionArray,L.DYNAMIC_DRAW),j.enableAttribute(X.position),L.vertexAttribPointer(X.position,3,L.FLOAT,!1,0,0)),x.hasNormals&&(L.bindBuffer(L.ARRAY_BUFFER,P.normal),L.bufferData(L.ARRAY_BUFFER,x.normalArray,L.DYNAMIC_DRAW),j.enableAttribute(X.normal),L.vertexAttribPointer(X.normal,3,L.FLOAT,!1,0,0)),x.hasUvs&&(L.bindBuffer(L.ARRAY_BUFFER,P.uv),L.bufferData(L.ARRAY_BUFFER,x.uvArray,L.DYNAMIC_DRAW),j.enableAttribute(X.uv),L.vertexAttribPointer(X.uv,2,L.FLOAT,!1,0,0)),x.hasColors&&(L.bindBuffer(L.ARRAY_BUFFER,P.color),L.bufferData(L.ARRAY_BUFFER,x.colorArray,L.DYNAMIC_DRAW),j.enableAttribute(X.color),L.vertexAttribPointer(X.color,3,L.FLOAT,!1,0,0)),j.disableUnusedAttributes(),L.drawArrays(L.TRIANGLES,0,x.count),x.count=0},this.renderBufferDirect=function(x,M,P,X,ee,Se){var re=ee.isMesh&&ee.normalMatrix.determinant()<0;j.setMaterial(X,re);var ie=gt(x,M,X,ee),ye=!1;(_.geometry!==P.id||_.program!==ie.id||_.wireframe!==(X.wireframe===!0))&&(_.geometry=P.id,_.program=ie.id,_.wireframe=X.wireframe===!0,ye=!0),ee.morphTargetInfluences&&(Ke.update(ee,P,X,ie),ye=!0);var Oe=P.index,Pe=P.attributes.position,Be=1;X.wireframe===!0&&(Oe=he.getWireframeAttribute(P),Be=2);var Ve,be=zt;Oe!==null&&(Ve=H.get(Oe),be=Lt,be.setIndex(Ve)),ye&&(ne(X,ie,P),Oe!==null&&L.bindBuffer(L.ELEMENT_ARRAY_BUFFER,Ve.buffer));var ue=1/0;Oe!==null?ue=Oe.count:Pe!==void 0&&(ue=Pe.count);var Le=P.drawRange.start*Be,Je=P.drawRange.count*Be,Pt=Se!==null?Se.start*Be:0,Xe=Se!==null?Se.count*Be:1/0,Ht=Math.max(Le,Pt),ki=Math.min(ue,Le+Je,Pt+Xe)-1,Yn=Math.max(0,ki-Ht+1);if(Yn!==0){if(ee.isMesh)if(X.wireframe===!0)j.setLineWidth(X.wireframeLinewidth*U()),be.setMode(L.LINES);else switch(ee.drawMode){case io:be.setMode(L.TRIANGLES);break;case tc:be.setMode(L.TRIANGLE_STRIP);break;case rc:be.setMode(L.TRIANGLE_FAN);break}else if(ee.isLine){var Zn=X.linewidth;Zn===void 0&&(Zn=1),j.setLineWidth(Zn*U()),ee.isLineSegments?be.setMode(L.LINES):ee.isLineLoop?be.setMode(L.LINE_LOOP):be.setMode(L.LINE_STRIP)}else ee.isPoints?be.setMode(L.POINTS):ee.isSprite&&be.setMode(L.TRIANGLES);P&&P.isInstancedBufferGeometry?P.maxInstancedCount>0&&be.renderInstances(P,Ht,Yn):be.render(Ht,Yn)}};function ne(x,M,P){if(P&&P.isInstancedBufferGeometry&!W.isWebGL2&&B.get("ANGLE_instanced_arrays")===null){console.error("THREE.WebGLRenderer.setupVertexAttributes: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}j.initAttributes();var X=P.attributes,ee=M.getAttributes(),Se=x.defaultAttributeValues;for(var re in ee){var ie=ee[re];if(ie>=0){var ye=X[re];if(ye!==void 0){var Oe=ye.normalized,Pe=ye.itemSize,Be=H.get(ye);if(Be===void 0)continue;var Ve=Be.buffer,be=Be.type,ue=Be.bytesPerElement;if(ye.isInterleavedBufferAttribute){var Le=ye.data,Je=Le.stride,Pt=ye.offset;Le&&Le.isInstancedInterleavedBuffer?(j.enableAttributeAndDivisor(ie,Le.meshPerAttribute),P.maxInstancedCount===void 0&&(P.maxInstancedCount=Le.meshPerAttribute*Le.count)):j.enableAttribute(ie),L.bindBuffer(L.ARRAY_BUFFER,Ve),L.vertexAttribPointer(ie,Pe,be,Oe,Je*ue,Pt*ue)}else ye.isInstancedBufferAttribute?(j.enableAttributeAndDivisor(ie,ye.meshPerAttribute),P.maxInstancedCount===void 0&&(P.maxInstancedCount=ye.meshPerAttribute*ye.count)):j.enableAttribute(ie),L.bindBuffer(L.ARRAY_BUFFER,Ve),L.vertexAttribPointer(ie,Pe,be,Oe,0,0)}else if(Se!==void 0){var Xe=Se[re];if(Xe!==void 0)switch(Xe.length){case 2:L.vertexAttrib2fv(ie,Xe);break;case 3:L.vertexAttrib3fv(ie,Xe);break;case 4:L.vertexAttrib4fv(ie,Xe);break;default:L.vertexAttrib1fv(ie,Xe)}}}}j.disableUnusedAttributes()}this.compile=function(x,M){l=ze.get(x,M),l.init(),x.traverse(function(P){P.isLight&&(l.pushLight(P),P.castShadow&&l.pushShadow(P))}),l.setupLights(M),x.traverse(function(P){if(P.material)if(Array.isArray(P.material))for(var X=0;X<P.material.length;X++)De(P.material[X],x.fog,P);else De(P.material,x.fog,P)})};var we=null;function se(x){$e.isPresenting()||we&&we(x)}var Ee=new Qa;Ee.setAnimationLoop(se),typeof window<"u"&&Ee.setContext(window),this.setAnimationLoop=function(x){we=x,$e.setAnimationLoop(x),Ee.start()},this.render=function(x,M,P,X){if(!(M&&M.isCamera)){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(!d){_.geometry=null,_.program=null,_.wireframe=!1,g=-1,w=null,x.autoUpdate===!0&&x.updateMatrixWorld(),M.parent===null&&M.updateMatrixWorld(),$e.enabled&&(M=$e.getCamera(M)),l=ze.get(x,M),l.init(),x.onBeforeRender(f,x,M,P),E.multiplyMatrices(M.projectionMatrix,M.matrixWorldInverse),G.setFromMatrix(E),q=this.localClippingEnabled,Y=J.init(this.clippingPlanes,q,M),u=rt.get(x,M),u.init(),Ie(x,M,0,f.sortObjects),f.sortObjects===!0&&u.sort(),Y&&J.beginShadows();var ee=l.state.shadowsArray;gr.render(ee,x,M),l.setupLights(M),Y&&J.endShadows(),this.info.autoReset&&this.info.reset(),P===void 0&&(P=null),this.setRenderTarget(P),Ye.render(u,x,M,X);var Se=u.opaque,re=u.transparent;if(x.overrideMaterial){var ie=x.overrideMaterial;Se.length&&Ce(Se,x,M,ie),re.length&&Ce(re,x,M,ie)}else Se.length&&Ce(Se,x,M),re.length&&Ce(re,x,M);P&&(le.updateRenderTargetMipmap(P),le.updateMultisampleRenderTarget(P)),j.buffers.depth.setTest(!0),j.buffers.depth.setMask(!0),j.buffers.color.setMask(!0),j.setPolygonOffset(!1),x.onAfterRender(f,x,M),$e.enabled&&$e.submitFrame(),u=null,l=null}};function Ie(x,M,P,X){if(x.visible!==!1){var ee=x.layers.test(M.layers);if(ee){if(x.isGroup)P=x.renderOrder;else if(x.isLight)l.pushLight(x),x.castShadow&&l.pushShadow(x);else if(x.isSprite){if(!x.frustumCulled||G.intersectsSprite(x)){X&&T.setFromMatrixPosition(x.matrixWorld).applyMatrix4(E);var Se=Re.update(x),re=x.material;u.push(x,Se,re,P,T.z,null)}}else if(x.isImmediateRenderObject)X&&T.setFromMatrixPosition(x.matrixWorld).applyMatrix4(E),u.push(x,null,x.material,P,T.z,null);else if((x.isMesh||x.isLine||x.isPoints)&&(x.isSkinnedMesh&&x.skeleton.update(),!x.frustumCulled||G.intersectsObject(x))){X&&T.setFromMatrixPosition(x.matrixWorld).applyMatrix4(E);var Se=Re.update(x),re=x.material;if(Array.isArray(re))for(var ie=Se.groups,ye=0,Oe=ie.length;ye<Oe;ye++){var Pe=ie[ye],Be=re[Pe.materialIndex];Be&&Be.visible&&u.push(x,Se,Be,P,T.z,Pe)}else re.visible&&u.push(x,Se,re,P,T.z,null)}}for(var Ve=x.children,ye=0,Oe=Ve.length;ye<Oe;ye++)Ie(Ve[ye],M,P,X)}}function Ce(x,M,P,X){for(var ee=0,Se=x.length;ee<Se;ee++){var re=x[ee],ie=re.object,ye=re.geometry,Oe=X===void 0?re.material:X,Pe=re.group;if(P.isArrayCamera){y=P;for(var Be=P.cameras,Ve=0,be=Be.length;Ve<be;Ve++){var ue=Be[Ve];if(ie.layers.test(ue.layers)){if("viewport"in ue)j.viewport(S.copy(ue.viewport));else{var Le=ue.bounds,Je=Le.x*A,Pt=Le.y*O,Xe=Le.z*A,Ht=Le.w*O;j.viewport(S.set(Je,Pt,Xe,Ht).multiplyScalar(F))}l.setupLights(ue),pt(ie,M,ue,ye,Oe,Pe)}}}else y=null,pt(ie,M,P,ye,Oe,Pe)}}function pt(x,M,P,X,ee,Se){if(x.onBeforeRender(f,M,P,X,ee,Se),l=ze.get(M,y||P),x.modelViewMatrix.multiplyMatrices(P.matrixWorldInverse,x.matrixWorld),x.normalMatrix.getNormalMatrix(x.modelViewMatrix),x.isImmediateRenderObject){j.setMaterial(ee);var re=gt(P,M.fog,ee,x);_.geometry=null,_.program=null,_.wireframe=!1,te(x,re)}else f.renderBufferDirect(P,M.fog,X,ee,x,Se);x.onAfterRender(f,M,P,X,ee,Se),l=ze.get(M,y||P)}function De(x,M,P){var X=me.get(x),ee=l.state.lights,Se=l.state.shadowsArray,re=X.lightsHash,ie=ee.state.hash,ye=_e.getParameters(x,ee.state,Se,M,J.numPlanes,J.numIntersection,P),Oe=_e.getProgramCode(x,ye),Pe=X.program,Be=!0;if(Pe===void 0)x.addEventListener("dispose",Me);else if(Pe.code!==Oe)D(x);else if(re.stateID!==ie.stateID||re.directionalLength!==ie.directionalLength||re.pointLength!==ie.pointLength||re.spotLength!==ie.spotLength||re.rectAreaLength!==ie.rectAreaLength||re.hemiLength!==ie.hemiLength||re.shadowsLength!==ie.shadowsLength)re.stateID=ie.stateID,re.directionalLength=ie.directionalLength,re.pointLength=ie.pointLength,re.spotLength=ie.spotLength,re.rectAreaLength=ie.rectAreaLength,re.hemiLength=ie.hemiLength,re.shadowsLength=ie.shadowsLength,Be=!1;else{if(ye.shaderID!==void 0)return;Be=!1}if(Be){if(ye.shaderID){var Ve=kt[ye.shaderID];X.shader={name:x.type,uniforms:ri(Ve.uniforms),vertexShader:Ve.vertexShader,fragmentShader:Ve.fragmentShader}}else X.shader={name:x.type,uniforms:x.uniforms,vertexShader:x.vertexShader,fragmentShader:x.fragmentShader};x.onBeforeCompile(X.shader,f),Oe=_e.getProgramCode(x,ye),Pe=_e.acquireProgram(x,X.shader,ye,Oe),X.program=Pe,x.program=Pe}var be=Pe.getAttributes();if(x.morphTargets){x.numSupportedMorphTargets=0;for(var ue=0;ue<f.maxMorphTargets;ue++)be["morphTarget"+ue]>=0&&x.numSupportedMorphTargets++}if(x.morphNormals){x.numSupportedMorphNormals=0;for(var ue=0;ue<f.maxMorphNormals;ue++)be["morphNormal"+ue]>=0&&x.numSupportedMorphNormals++}var Le=X.shader.uniforms;(!x.isShaderMaterial&&!x.isRawShaderMaterial||x.clipping===!0)&&(X.numClippingPlanes=J.numPlanes,X.numIntersection=J.numIntersection,Le.clippingPlanes=J.uniform),X.fog=M,re===void 0&&(X.lightsHash=re={}),re.stateID=ie.stateID,re.directionalLength=ie.directionalLength,re.pointLength=ie.pointLength,re.spotLength=ie.spotLength,re.rectAreaLength=ie.rectAreaLength,re.hemiLength=ie.hemiLength,re.shadowsLength=ie.shadowsLength,x.lights&&(Le.ambientLightColor.value=ee.state.ambient,Le.directionalLights.value=ee.state.directional,Le.spotLights.value=ee.state.spot,Le.rectAreaLights.value=ee.state.rectArea,Le.pointLights.value=ee.state.point,Le.hemisphereLights.value=ee.state.hemi,Le.directionalShadowMap.value=ee.state.directionalShadowMap,Le.directionalShadowMatrix.value=ee.state.directionalShadowMatrix,Le.spotShadowMap.value=ee.state.spotShadowMap,Le.spotShadowMatrix.value=ee.state.spotShadowMatrix,Le.pointShadowMap.value=ee.state.pointShadowMap,Le.pointShadowMatrix.value=ee.state.pointShadowMatrix);var Je=X.program.getUniforms(),Pt=$t.seqWithValue(Je.seq,Le);X.uniformsList=Pt}function gt(x,M,P,X){C=0;var ee=me.get(P),Se=l.state.lights,re=ee.lightsHash,ie=Se.state.hash;if(Y&&(q||x!==w)){var ye=x===w&&P.id===g;J.setState(P.clippingPlanes,P.clipIntersection,P.clipShadows,x,ee,ye)}P.needsUpdate===!1&&(ee.program===void 0||P.fog&&ee.fog!==M||P.lights&&(re.stateID!==ie.stateID||re.directionalLength!==ie.directionalLength||re.pointLength!==ie.pointLength||re.spotLength!==ie.spotLength||re.rectAreaLength!==ie.rectAreaLength||re.hemiLength!==ie.hemiLength||re.shadowsLength!==ie.shadowsLength)||ee.numClippingPlanes!==void 0&&(ee.numClippingPlanes!==J.numPlanes||ee.numIntersection!==J.numIntersection))&&(P.needsUpdate=!0),P.needsUpdate&&(De(P,M,X),P.needsUpdate=!1);var Oe=!1,Pe=!1,Be=!1,Ve=ee.program,be=Ve.getUniforms(),ue=ee.shader.uniforms;if(j.useProgram(Ve.program)&&(Oe=!0,Pe=!0,Be=!0),P.id!==g&&(g=P.id,Pe=!0),Oe||w!==x){if(be.setValue(L,"projectionMatrix",x.projectionMatrix),W.logarithmicDepthBuffer&&be.setValue(L,"logDepthBufFC",2/(Math.log(x.far+1)/Math.LN2)),w!==x&&(w=x,Pe=!0,Be=!0),P.isShaderMaterial||P.isMeshPhongMaterial||P.isMeshStandardMaterial||P.envMap){var Le=be.map.cameraPosition;Le!==void 0&&Le.setValue(L,T.setFromMatrixPosition(x.matrixWorld))}(P.isMeshPhongMaterial||P.isMeshLambertMaterial||P.isMeshBasicMaterial||P.isMeshStandardMaterial||P.isShaderMaterial||P.skinning)&&be.setValue(L,"viewMatrix",x.matrixWorldInverse)}if(P.skinning){be.setOptional(L,X,"bindMatrix"),be.setOptional(L,X,"bindMatrixInverse");var Je=X.skeleton;if(Je){var Pt=Je.bones;if(W.floatVertexTextures){if(Je.boneTexture===void 0){var Xe=Math.sqrt(Pt.length*4);Xe=ge.ceilPowerOfTwo(Xe),Xe=Math.max(Xe,4);var Ht=new Float32Array(Xe*Xe*4);Ht.set(Je.boneMatrices);var ki=new Sr(Ht,Xe,Xe,Wt,$r);ki.needsUpdate=!0,Je.boneMatrices=Ht,Je.boneTexture=ki,Je.boneTextureSize=Xe}be.setValue(L,"boneTexture",Je.boneTexture),be.setValue(L,"boneTextureSize",Je.boneTextureSize)}else be.setOptional(L,Je,"boneMatrices")}}return Pe&&(be.setValue(L,"toneMappingExposure",f.toneMappingExposure),be.setValue(L,"toneMappingWhitePoint",f.toneMappingWhitePoint),P.lights&&Ko(ue,Be),M&&P.fog&&Hi(ue,M),P.isMeshBasicMaterial?qe(ue,P):P.isMeshLambertMaterial?(qe(ue,P),Vi(ue,P)):P.isMeshPhongMaterial?(qe(ue,P),P.isMeshToonMaterial?jo(ue,P):sr(ue,P)):P.isMeshStandardMaterial?(qe(ue,P),P.isMeshPhysicalMaterial?qo(ue,P):rs(ue,P)):P.isMeshMatcapMaterial?(qe(ue,P),Yo(ue,P)):P.isMeshDepthMaterial?(qe(ue,P),Zo(ue,P)):P.isMeshDistanceMaterial?(qe(ue,P),Jo(ue,P)):P.isMeshNormalMaterial?(qe(ue,P),Qo(ue,P)):P.isLineBasicMaterial?(Gi(ue,P),P.isLineDashedMaterial&&zi(ue,P)):P.isPointsMaterial?jn(ue,P):P.isSpriteMaterial?qn(ue,P):P.isShadowMaterial&&(ue.color.value=P.color,ue.opacity.value=P.opacity),ue.ltc_1!==void 0&&(ue.ltc_1.value=ae.LTC_1),ue.ltc_2!==void 0&&(ue.ltc_2.value=ae.LTC_2),$t.upload(L,ee.uniformsList,ue,f)),P.isShaderMaterial&&P.uniformsNeedUpdate===!0&&($t.upload(L,ee.uniformsList,ue,f),P.uniformsNeedUpdate=!1),P.isSpriteMaterial&&be.setValue(L,"center",X.center),be.setValue(L,"modelViewMatrix",X.modelViewMatrix),be.setValue(L,"normalMatrix",X.normalMatrix),be.setValue(L,"modelMatrix",X.matrixWorld),Ve}function qe(x,M){x.opacity.value=M.opacity,M.color&&(x.diffuse.value=M.color),M.emissive&&x.emissive.value.copy(M.emissive).multiplyScalar(M.emissiveIntensity),M.map&&(x.map.value=M.map),M.alphaMap&&(x.alphaMap.value=M.alphaMap),M.specularMap&&(x.specularMap.value=M.specularMap),M.envMap&&(x.envMap.value=M.envMap,x.flipEnvMap.value=M.envMap.isCubeTexture?-1:1,x.reflectivity.value=M.reflectivity,x.refractionRatio.value=M.refractionRatio,x.maxMipLevel.value=me.get(M.envMap).__maxMipLevel),M.lightMap&&(x.lightMap.value=M.lightMap,x.lightMapIntensity.value=M.lightMapIntensity),M.aoMap&&(x.aoMap.value=M.aoMap,x.aoMapIntensity.value=M.aoMapIntensity);var P;M.map?P=M.map:M.specularMap?P=M.specularMap:M.displacementMap?P=M.displacementMap:M.normalMap?P=M.normalMap:M.bumpMap?P=M.bumpMap:M.roughnessMap?P=M.roughnessMap:M.metalnessMap?P=M.metalnessMap:M.alphaMap?P=M.alphaMap:M.emissiveMap&&(P=M.emissiveMap),P!==void 0&&(P.isWebGLRenderTarget&&(P=P.texture),P.matrixAutoUpdate===!0&&P.updateMatrix(),x.uvTransform.value.copy(P.matrix))}function Gi(x,M){x.diffuse.value=M.color,x.opacity.value=M.opacity}function zi(x,M){x.dashSize.value=M.dashSize,x.totalSize.value=M.dashSize+M.gapSize,x.scale.value=M.scale}function jn(x,M){x.diffuse.value=M.color,x.opacity.value=M.opacity,x.size.value=M.size*F,x.scale.value=O*.5,x.map.value=M.map,M.map!==null&&(M.map.matrixAutoUpdate===!0&&M.map.updateMatrix(),x.uvTransform.value.copy(M.map.matrix))}function qn(x,M){x.diffuse.value=M.color,x.opacity.value=M.opacity,x.rotation.value=M.rotation,x.map.value=M.map,M.map!==null&&(M.map.matrixAutoUpdate===!0&&M.map.updateMatrix(),x.uvTransform.value.copy(M.map.matrix))}function Hi(x,M){x.fogColor.value=M.color,M.isFog?(x.fogNear.value=M.near,x.fogFar.value=M.far):M.isFogExp2&&(x.fogDensity.value=M.density)}function Vi(x,M){M.emissiveMap&&(x.emissiveMap.value=M.emissiveMap)}function sr(x,M){x.specular.value=M.specular,x.shininess.value=Math.max(M.shininess,1e-4),M.emissiveMap&&(x.emissiveMap.value=M.emissiveMap),M.bumpMap&&(x.bumpMap.value=M.bumpMap,x.bumpScale.value=M.bumpScale,M.side===st&&(x.bumpScale.value*=-1)),M.normalMap&&(x.normalMap.value=M.normalMap,x.normalScale.value.copy(M.normalScale),M.side===st&&x.normalScale.value.negate()),M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias)}function jo(x,M){sr(x,M),M.gradientMap&&(x.gradientMap.value=M.gradientMap)}function rs(x,M){x.roughness.value=M.roughness,x.metalness.value=M.metalness,M.roughnessMap&&(x.roughnessMap.value=M.roughnessMap),M.metalnessMap&&(x.metalnessMap.value=M.metalnessMap),M.emissiveMap&&(x.emissiveMap.value=M.emissiveMap),M.bumpMap&&(x.bumpMap.value=M.bumpMap,x.bumpScale.value=M.bumpScale,M.side===st&&(x.bumpScale.value*=-1)),M.normalMap&&(x.normalMap.value=M.normalMap,x.normalScale.value.copy(M.normalScale),M.side===st&&x.normalScale.value.negate()),M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias),M.envMap&&(x.envMapIntensity.value=M.envMapIntensity)}function qo(x,M){rs(x,M),x.reflectivity.value=M.reflectivity,x.clearCoat.value=M.clearCoat,x.clearCoatRoughness.value=M.clearCoatRoughness}function Yo(x,M){M.matcap&&(x.matcap.value=M.matcap),M.bumpMap&&(x.bumpMap.value=M.bumpMap,x.bumpScale.value=M.bumpScale,M.side===st&&(x.bumpScale.value*=-1)),M.normalMap&&(x.normalMap.value=M.normalMap,x.normalScale.value.copy(M.normalScale),M.side===st&&x.normalScale.value.negate()),M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias)}function Zo(x,M){M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias)}function Jo(x,M){M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias),x.referencePosition.value.copy(M.referencePosition),x.nearDistance.value=M.nearDistance,x.farDistance.value=M.farDistance}function Qo(x,M){M.bumpMap&&(x.bumpMap.value=M.bumpMap,x.bumpScale.value=M.bumpScale,M.side===st&&(x.bumpScale.value*=-1)),M.normalMap&&(x.normalMap.value=M.normalMap,x.normalScale.value.copy(M.normalScale),M.side===st&&x.normalScale.value.negate()),M.displacementMap&&(x.displacementMap.value=M.displacementMap,x.displacementScale.value=M.displacementScale,x.displacementBias.value=M.displacementBias)}function Ko(x,M){x.ambientLightColor.needsUpdate=M,x.directionalLights.needsUpdate=M,x.pointLights.needsUpdate=M,x.spotLights.needsUpdate=M,x.rectAreaLights.needsUpdate=M,x.hemisphereLights.needsUpdate=M}function $o(){var x=C;return x>=W.maxTextures&&console.warn("THREE.WebGLRenderer: Trying to use "+x+" texture units while this GPU supports only "+W.maxTextures),C+=1,x}this.allocTextureUnit=$o,this.setTexture2D=function(){var x=!1;return function(P,X){P&&P.isWebGLRenderTarget&&(x||(console.warn("THREE.WebGLRenderer.setTexture2D: don't use render targets as textures. Use their .texture property instead."),x=!0),P=P.texture),le.setTexture2D(P,X)}}(),this.setTexture3D=function(){return function(M,P){le.setTexture3D(M,P)}}(),this.setTexture=function(){var x=!1;return function(P,X){x||(console.warn("THREE.WebGLRenderer: .setTexture is deprecated, use setTexture2D instead."),x=!0),le.setTexture2D(P,X)}}(),this.setTextureCube=function(){var x=!1;return function(P,X){P&&P.isWebGLRenderTargetCube&&(x||(console.warn("THREE.WebGLRenderer.setTextureCube: don't use cube render targets as textures. Use their .texture property instead."),x=!0),P=P.texture),P&&P.isCubeTexture||Array.isArray(P.image)&&P.image.length===6?le.setTextureCube(P,X):le.setTextureCubeDynamic(P,X)}}(),this.setFramebuffer=function(x){p=x},this.getRenderTarget=function(){return m},this.setRenderTarget=function(x){m=x,x&&me.get(x).__webglFramebuffer===void 0&&le.setupRenderTarget(x);var M=p,P=!1;if(x){var X=me.get(x).__webglFramebuffer;x.isWebGLRenderTargetCube?(M=X[x.activeCubeFace],P=!0):x.isWebGLMultisampleRenderTarget?M=me.get(x).__webglMultisampledFramebuffer:M=X,S.copy(x.viewport),R.copy(x.scissor),I=x.scissorTest}else S.copy(N).multiplyScalar(F),R.copy(V).multiplyScalar(F),I=k;if(v!==M&&(L.bindFramebuffer(L.FRAMEBUFFER,M),v=M),j.viewport(S),j.scissor(R),j.setScissorTest(I),P){var ee=me.get(x.texture);L.framebufferTexture2D(L.FRAMEBUFFER,L.COLOR_ATTACHMENT0,L.TEXTURE_CUBE_MAP_POSITIVE_X+x.activeCubeFace,ee.__webglTexture,x.activeMipMapLevel)}},this.readRenderTargetPixels=function(x,M,P,X,ee,Se){if(!(x&&x.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}var re=me.get(x).__webglFramebuffer;if(re){var ie=!1;re!==v&&(L.bindFramebuffer(L.FRAMEBUFFER,re),ie=!0);try{var ye=x.texture,Oe=ye.format,Pe=ye.type;if(Oe!==Wt&&We.convert(Oe)!==L.getParameter(L.IMPLEMENTATION_COLOR_READ_FORMAT)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}if(Pe!==kn&&We.convert(Pe)!==L.getParameter(L.IMPLEMENTATION_COLOR_READ_TYPE)&&!(Pe===$r&&(W.isWebGL2||B.get("OES_texture_float")||B.get("WEBGL_color_buffer_float")))&&!(Pe===Za&&(W.isWebGL2?B.get("EXT_color_buffer_float"):B.get("EXT_color_buffer_half_float")))){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}L.checkFramebufferStatus(L.FRAMEBUFFER)===L.FRAMEBUFFER_COMPLETE?M>=0&&M<=x.width-X&&P>=0&&P<=x.height-ee&&L.readPixels(M,P,X,ee,We.convert(Oe),We.convert(Pe),Se):console.error("THREE.WebGLRenderer.readRenderTargetPixels: readPixels from renderTarget failed. Framebuffer not complete.")}finally{ie&&L.bindFramebuffer(L.FRAMEBUFFER,v)}}},this.copyFramebufferToTexture=function(x,M,P){var X=M.image.width,ee=M.image.height,Se=We.convert(M.format);this.setTexture2D(M,0),L.copyTexImage2D(L.TEXTURE_2D,P||0,Se,x.x,x.y,X,ee,0)},this.copyTextureToTexture=function(x,M,P,X){var ee=M.image.width,Se=M.image.height,re=We.convert(P.format),ie=We.convert(P.type);this.setTexture2D(P,0),M.isDataTexture?L.texSubImage2D(L.TEXTURE_2D,X||0,x.x,x.y,ee,Se,re,ie,M.image.data):L.texSubImage2D(L.TEXTURE_2D,X||0,x.x,x.y,re,ie,M.image)}}function oi(e,t){this.name="",this.color=new oe(e),this.density=t!==void 0?t:25e-5}oi.prototype.isFogExp2=!0;oi.prototype.clone=function(){return new oi(this.color,this.density)};oi.prototype.toJSON=function(){return{type:"FogExp2",color:this.color.getHex(),density:this.density}};function hi(e,t,r){this.name="",this.color=new oe(e),this.near=t!==void 0?t:1,this.far=r!==void 0?r:1e3}hi.prototype.isFog=!0;hi.prototype.clone=function(){return new hi(this.color,this.near,this.far)};hi.prototype.toJSON=function(){return{type:"Fog",color:this.color.getHex(),near:this.near,far:this.far}};function an(){K.call(this),this.type="Scene",this.background=null,this.fog=null,this.overrideMaterial=null,this.autoUpdate=!0}an.prototype=Object.assign(Object.create(K.prototype),{constructor:an,copy:function(e,t){return K.prototype.copy.call(this,e,t),e.background!==null&&(this.background=e.background.clone()),e.fog!==null&&(this.fog=e.fog.clone()),e.overrideMaterial!==null&&(this.overrideMaterial=e.overrideMaterial.clone()),this.autoUpdate=e.autoUpdate,this.matrixAutoUpdate=e.matrixAutoUpdate,this},toJSON:function(e){var t=K.prototype.toJSON.call(this,e);return this.background!==null&&(t.object.background=this.background.toJSON(e)),this.fog!==null&&(t.object.fog=this.fog.toJSON()),t},dispose:function(){this.dispatchEvent({type:"dispose"})}});function Lr(e,t){this.array=e,this.stride=t,this.count=e!==void 0?e.length/t:0,this.dynamic=!1,this.updateRange={offset:0,count:-1},this.version=0}Object.defineProperty(Lr.prototype,"needsUpdate",{set:function(e){e===!0&&this.version++}});Object.assign(Lr.prototype,{isInterleavedBuffer:!0,onUploadCallback:function(){},setArray:function(e){if(Array.isArray(e))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");return this.count=e!==void 0?e.length/this.stride:0,this.array=e,this},setDynamic:function(e){return this.dynamic=e,this},copy:function(e){return this.array=new e.array.constructor(e.array),this.count=e.count,this.stride=e.stride,this.dynamic=e.dynamic,this},copyAt:function(e,t,r){e*=this.stride,r*=t.stride;for(var i=0,n=this.stride;i<n;i++)this.array[e+i]=t.array[r+i];return this},set:function(e,t){return t===void 0&&(t=0),this.array.set(e,t),this},clone:function(){return new this.constructor().copy(this)},onUpload:function(e){return this.onUploadCallback=e,this}});function sn(e,t,r,i){this.data=e,this.itemSize=t,this.offset=r,this.normalized=i===!0}Object.defineProperties(sn.prototype,{count:{get:function(){return this.data.count}},array:{get:function(){return this.data.array}}});Object.assign(sn.prototype,{isInterleavedBufferAttribute:!0,setX:function(e,t){return this.data.array[e*this.data.stride+this.offset]=t,this},setY:function(e,t){return this.data.array[e*this.data.stride+this.offset+1]=t,this},setZ:function(e,t){return this.data.array[e*this.data.stride+this.offset+2]=t,this},setW:function(e,t){return this.data.array[e*this.data.stride+this.offset+3]=t,this},getX:function(e){return this.data.array[e*this.data.stride+this.offset]},getY:function(e){return this.data.array[e*this.data.stride+this.offset+1]},getZ:function(e){return this.data.array[e*this.data.stride+this.offset+2]},getW:function(e){return this.data.array[e*this.data.stride+this.offset+3]},setXY:function(e,t,r){return e=e*this.data.stride+this.offset,this.data.array[e+0]=t,this.data.array[e+1]=r,this},setXYZ:function(e,t,r,i){return e=e*this.data.stride+this.offset,this.data.array[e+0]=t,this.data.array[e+1]=r,this.data.array[e+2]=i,this},setXYZW:function(e,t,r,i,n){return e=e*this.data.stride+this.offset,this.data.array[e+0]=t,this.data.array[e+1]=r,this.data.array[e+2]=i,this.data.array[e+3]=n,this}});function pr(e){ve.call(this),this.type="SpriteMaterial",this.color=new oe(16777215),this.map=null,this.rotation=0,this.sizeAttenuation=!0,this.lights=!1,this.transparent=!0,this.setValues(e)}pr.prototype=Object.create(ve.prototype);pr.prototype.constructor=pr;pr.prototype.isSpriteMaterial=!0;pr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.map=e.map,this.rotation=e.rotation,this.sizeAttenuation=e.sizeAttenuation,this};var xr;function xa(e){if(K.call(this),this.type="Sprite",xr===void 0){xr=new $;var t=new Float32Array([-.5,-.5,0,0,0,.5,-.5,0,1,0,.5,.5,0,1,1,-.5,.5,0,0,1]),r=new Lr(t,5);xr.setIndex([0,1,2,0,2,3]),xr.addAttribute("position",new sn(r,3,0,!1)),xr.addAttribute("uv",new sn(r,2,3,!1))}this.geometry=xr,this.material=e!==void 0?e:new pr,this.center=new z(.5,.5)}xa.prototype=Object.assign(Object.create(K.prototype),{constructor:xa,isSprite:!0,raycast:function(){var e=new b,t=new b,r=new b,i=new z,n=new z,a=new fe,s=new b,o=new b,h=new b,c=new z,u=new z,l=new z;function f(d,p,m,v,g,_){i.subVectors(d,m).addScalar(.5).multiply(v),g!==void 0?(n.x=_*i.x-g*i.y,n.y=g*i.x+_*i.y):n.copy(i),d.copy(p),d.x+=n.x,d.y+=n.y,d.applyMatrix4(a)}return function(p,m){t.setFromMatrixScale(this.matrixWorld),a.getInverse(this.modelViewMatrix).premultiply(this.matrixWorld),r.setFromMatrixPosition(this.modelViewMatrix);var v=this.material.rotation,g,_;v!==0&&(_=Math.cos(v),g=Math.sin(v));var w=this.center;f(s.set(-.5,-.5,0),r,w,t,g,_),f(o.set(.5,-.5,0),r,w,t,g,_),f(h.set(.5,.5,0),r,w,t,g,_),c.set(0,0),u.set(1,0),l.set(1,1);var y=p.ray.intersectTriangle(s,o,h,!1,e);if(!(y===null&&(f(o.set(-.5,.5,0),r,w,t,g,_),u.set(0,1),y=p.ray.intersectTriangle(s,h,o,!1,e),y===null))){var S=p.ray.origin.distanceTo(e);S<p.near||S>p.far||m.push({distance:S,point:e.clone(),uv:ot.getUV(e,s,o,h,c,u,l,new z),face:null,object:this})}}}(),clone:function(){return new this.constructor(this.material).copy(this)},copy:function(e){return K.prototype.copy.call(this,e),e.center!==void 0&&this.center.copy(e.center),this}});function on(){K.call(this),this.type="LOD",Object.defineProperties(this,{levels:{enumerable:!0,value:[]}})}on.prototype=Object.assign(Object.create(K.prototype),{constructor:on,copy:function(e){K.prototype.copy.call(this,e,!1);for(var t=e.levels,r=0,i=t.length;r<i;r++){var n=t[r];this.addLevel(n.object.clone(),n.distance)}return this},addLevel:function(e,t){t===void 0&&(t=0),t=Math.abs(t);for(var r=this.levels,i=0;i<r.length&&!(t<r[i].distance);i++);r.splice(i,0,{distance:t,object:e}),this.add(e)},getObjectForDistance:function(e){for(var t=this.levels,r=1,i=t.length;r<i&&!(e<t[r].distance);r++);return t[r-1].object},raycast:function(){var e=new b;return function(r,i){e.setFromMatrixPosition(this.matrixWorld);var n=r.ray.origin.distanceTo(e);this.getObjectForDistance(n).raycast(r,i)}}(),update:function(){var e=new b,t=new b;return function(i){var n=this.levels;if(n.length>1){e.setFromMatrixPosition(i.matrixWorld),t.setFromMatrixPosition(this.matrixWorld);var a=e.distanceTo(t);n[0].object.visible=!0;for(var s=1,o=n.length;s<o&&a>=n[s].distance;s++)n[s-1].object.visible=!1,n[s].object.visible=!0;for(;s<o;s++)n[s].object.visible=!1}}}(),toJSON:function(e){var t=K.prototype.toJSON.call(this,e);t.object.levels=[];for(var r=this.levels,i=0,n=r.length;i<n;i++){var a=r[i];t.object.levels.push({object:a.object.uuid,distance:a.distance})}return t}});function hn(e,t){e&&e.isGeometry&&console.error("THREE.SkinnedMesh no longer supports THREE.Geometry. Use THREE.BufferGeometry instead."),lt.call(this,e,t),this.type="SkinnedMesh",this.bindMode="attached",this.bindMatrix=new fe,this.bindMatrixInverse=new fe}hn.prototype=Object.assign(Object.create(lt.prototype),{constructor:hn,isSkinnedMesh:!0,bind:function(e,t){this.skeleton=e,t===void 0&&(this.updateMatrixWorld(!0),this.skeleton.calculateInverses(),t=this.matrixWorld),this.bindMatrix.copy(t),this.bindMatrixInverse.getInverse(t)},pose:function(){this.skeleton.pose()},normalizeSkinWeights:function(){for(var e=new Fe,t=this.geometry.attributes.skinWeight,r=0,i=t.count;r<i;r++){e.x=t.getX(r),e.y=t.getY(r),e.z=t.getZ(r),e.w=t.getW(r);var n=1/e.manhattanLength();n!==1/0?e.multiplyScalar(n):e.set(1,0,0,0),t.setXYZW(r,e.x,e.y,e.z,e.w)}},updateMatrixWorld:function(e){lt.prototype.updateMatrixWorld.call(this,e),this.bindMode==="attached"?this.bindMatrixInverse.getInverse(this.matrixWorld):this.bindMode==="detached"?this.bindMatrixInverse.getInverse(this.bindMatrix):console.warn("THREE.SkinnedMesh: Unrecognized bindMode: "+this.bindMode)},clone:function(){return new this.constructor(this.geometry,this.material).copy(this)}});function _a(e,t){if(e=e||[],this.bones=e.slice(0),this.boneMatrices=new Float32Array(this.bones.length*16),t===void 0)this.calculateInverses();else if(this.bones.length===t.length)this.boneInverses=t.slice(0);else{console.warn("THREE.Skeleton boneInverses is the wrong length."),this.boneInverses=[];for(var r=0,i=this.bones.length;r<i;r++)this.boneInverses.push(new fe)}}Object.assign(_a.prototype,{calculateInverses:function(){this.boneInverses=[];for(var e=0,t=this.bones.length;e<t;e++){var r=new fe;this.bones[e]&&r.getInverse(this.bones[e].matrixWorld),this.boneInverses.push(r)}},pose:function(){var e,t,r;for(t=0,r=this.bones.length;t<r;t++)e=this.bones[t],e&&e.matrixWorld.getInverse(this.boneInverses[t]);for(t=0,r=this.bones.length;t<r;t++)e=this.bones[t],e&&(e.parent&&e.parent.isBone?(e.matrix.getInverse(e.parent.matrixWorld),e.matrix.multiply(e.matrixWorld)):e.matrix.copy(e.matrixWorld),e.matrix.decompose(e.position,e.quaternion,e.scale))},update:function(){var e=new fe,t=new fe;return function(){for(var i=this.bones,n=this.boneInverses,a=this.boneMatrices,s=this.boneTexture,o=0,h=i.length;o<h;o++){var c=i[o]?i[o].matrixWorld:t;e.multiplyMatrices(c,n[o]),e.toArray(a,o*16)}s!==void 0&&(s.needsUpdate=!0)}}(),clone:function(){return new _a(this.bones,this.boneInverses)},getBoneByName:function(e){for(var t=0,r=this.bones.length;t<r;t++){var i=this.bones[t];if(i.name===e)return i}}});function As(){K.call(this),this.type="Bone"}As.prototype=Object.assign(Object.create(K.prototype),{constructor:As,isBone:!0});function Ne(e){ve.call(this),this.type="LineBasicMaterial",this.color=new oe(16777215),this.linewidth=1,this.linecap="round",this.linejoin="round",this.lights=!1,this.setValues(e)}Ne.prototype=Object.create(ve.prototype);Ne.prototype.constructor=Ne;Ne.prototype.isLineBasicMaterial=!0;Ne.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.linewidth=e.linewidth,this.linecap=e.linecap,this.linejoin=e.linejoin,this};function vt(e,t,r){r===1&&console.error("THREE.Line: parameter THREE.LinePieces no longer supported. Use THREE.LineSegments instead."),K.call(this),this.type="Line",this.geometry=e!==void 0?e:new $,this.material=t!==void 0?t:new Ne({color:Math.random()*16777215})}vt.prototype=Object.assign(Object.create(K.prototype),{constructor:vt,isLine:!0,computeLineDistances:function(){var e=new b,t=new b;return function(){var i=this.geometry;if(i.isBufferGeometry)if(i.index===null){for(var n=i.attributes.position,a=[0],s=1,o=n.count;s<o;s++)e.fromBufferAttribute(n,s-1),t.fromBufferAttribute(n,s),a[s]=a[s-1],a[s]+=e.distanceTo(t);i.addAttribute("lineDistance",new Z(a,1))}else console.warn("THREE.Line.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");else if(i.isGeometry){var h=i.vertices,a=i.lineDistances;a[0]=0;for(var s=1,o=h.length;s<o;s++)a[s]=a[s-1],a[s]+=h[s-1].distanceTo(h[s])}return this}}(),raycast:function(){var e=new fe,t=new jr,r=new Ot;return function(n,a){var s=n.linePrecision,o=this.geometry,h=this.matrixWorld;if(o.boundingSphere===null&&o.computeBoundingSphere(),r.copy(o.boundingSphere),r.applyMatrix4(h),r.radius+=s,n.ray.intersectsSphere(r)!==!1){e.getInverse(h),t.copy(n.ray).applyMatrix4(e);var c=s/((this.scale.x+this.scale.y+this.scale.z)/3),u=c*c,l=new b,f=new b,d=new b,p=new b,m=this&&this.isLineSegments?2:1;if(o.isBufferGeometry){var v=o.index,g=o.attributes,_=g.position.array;if(v!==null)for(var w=v.array,y=0,S=w.length-1;y<S;y+=m){var R=w[y],I=w[y+1];l.fromArray(_,R*3),f.fromArray(_,I*3);var C=t.distanceSqToSegment(l,f,p,d);if(!(C>u)){p.applyMatrix4(this.matrixWorld);var A=n.ray.origin.distanceTo(p);A<n.near||A>n.far||a.push({distance:A,point:d.clone().applyMatrix4(this.matrixWorld),index:y,face:null,faceIndex:null,object:this})}}else for(var y=0,S=_.length/3-1;y<S;y+=m){l.fromArray(_,3*y),f.fromArray(_,3*y+3);var C=t.distanceSqToSegment(l,f,p,d);if(!(C>u)){p.applyMatrix4(this.matrixWorld);var A=n.ray.origin.distanceTo(p);A<n.near||A>n.far||a.push({distance:A,point:d.clone().applyMatrix4(this.matrixWorld),index:y,face:null,faceIndex:null,object:this})}}}else if(o.isGeometry)for(var O=o.vertices,F=O.length,y=0;y<F-1;y+=m){var C=t.distanceSqToSegment(O[y],O[y+1],p,d);if(!(C>u)){p.applyMatrix4(this.matrixWorld);var A=n.ray.origin.distanceTo(p);A<n.near||A>n.far||a.push({distance:A,point:d.clone().applyMatrix4(this.matrixWorld),index:y,face:null,faceIndex:null,object:this})}}}}}(),copy:function(e){return K.prototype.copy.call(this,e),this.geometry.copy(e.geometry),this.material.copy(e.material),this},clone:function(){return new this.constructor().copy(this)}});function Ge(e,t){vt.call(this,e,t),this.type="LineSegments"}Ge.prototype=Object.assign(Object.create(vt.prototype),{constructor:Ge,isLineSegments:!0,computeLineDistances:function(){var e=new b,t=new b;return function(){var i=this.geometry;if(i.isBufferGeometry)if(i.index===null){for(var n=i.attributes.position,a=[],s=0,o=n.count;s<o;s+=2)e.fromBufferAttribute(n,s),t.fromBufferAttribute(n,s+1),a[s]=s===0?0:a[s-1],a[s+1]=a[s]+e.distanceTo(t);i.addAttribute("lineDistance",new Z(a,1))}else console.warn("THREE.LineSegments.computeLineDistances(): Computation only possible with non-indexed BufferGeometry.");else if(i.isGeometry)for(var h=i.vertices,a=i.lineDistances,s=0,o=h.length;s<o;s+=2)e.copy(h[s]),t.copy(h[s+1]),a[s]=s===0?0:a[s-1],a[s+1]=a[s]+e.distanceTo(t);return this}}()});function wa(e,t){vt.call(this,e,t),this.type="LineLoop"}wa.prototype=Object.assign(Object.create(vt.prototype),{constructor:wa,isLineLoop:!0});function mr(e){ve.call(this),this.type="PointsMaterial",this.color=new oe(16777215),this.map=null,this.size=1,this.sizeAttenuation=!0,this.morphTargets=!1,this.lights=!1,this.setValues(e)}mr.prototype=Object.create(ve.prototype);mr.prototype.constructor=mr;mr.prototype.isPointsMaterial=!0;mr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.map=e.map,this.size=e.size,this.sizeAttenuation=e.sizeAttenuation,this.morphTargets=e.morphTargets,this};function ba(e,t){K.call(this),this.type="Points",this.geometry=e!==void 0?e:new $,this.material=t!==void 0?t:new mr({color:Math.random()*16777215})}ba.prototype=Object.assign(Object.create(K.prototype),{constructor:ba,isPoints:!0,raycast:function(){var e=new fe,t=new jr,r=new Ot;return function(n,a){var s=this,o=this.geometry,h=this.matrixWorld,c=n.params.Points.threshold;if(o.boundingSphere===null&&o.computeBoundingSphere(),r.copy(o.boundingSphere),r.applyMatrix4(h),r.radius+=c,n.ray.intersectsSphere(r)===!1)return;e.getInverse(h),t.copy(n.ray).applyMatrix4(e);var u=c/((this.scale.x+this.scale.y+this.scale.z)/3),l=u*u,f=new b,d=new b;function p(C,A){var O=t.distanceSqToPoint(C);if(O<l){t.closestPointToPoint(C,d),d.applyMatrix4(h);var F=n.ray.origin.distanceTo(d);if(F<n.near||F>n.far)return;a.push({distance:F,distanceToRay:Math.sqrt(O),point:d.clone(),index:A,face:null,object:s})}}if(o.isBufferGeometry){var m=o.index,v=o.attributes,g=v.position.array;if(m!==null)for(var _=m.array,w=0,y=_.length;w<y;w++){var S=_[w];f.fromArray(g,S*3),p(f,S)}else for(var w=0,R=g.length/3;w<R;w++)f.fromArray(g,w*3),p(f,w)}else for(var I=o.vertices,w=0,R=I.length;w<R;w++)p(I[w],w)}}(),clone:function(){return new this.constructor(this.geometry,this.material).copy(this)}});function Ls(e,t,r,i,n,a,s,o,h){Ue.call(this,e,t,r,i,n,a,s,o,h),this.format=s!==void 0?s:cr,this.minFilter=a!==void 0?a:it,this.magFilter=n!==void 0?n:it,this.generateMipmaps=!1}Ls.prototype=Object.assign(Object.create(Ue.prototype),{constructor:Ls,isVideoTexture:!0,update:function(){var e=this.image;e.readyState>=e.HAVE_CURRENT_DATA&&(this.needsUpdate=!0)}});function ci(e,t,r,i,n,a,s,o,h,c,u,l){Ue.call(this,null,a,s,o,h,c,i,n,u,l),this.image={width:t,height:r},this.mipmaps=e,this.flipY=!1,this.generateMipmaps=!1}ci.prototype=Object.create(Ue.prototype);ci.prototype.constructor=ci;ci.prototype.isCompressedTexture=!0;function cn(e,t,r,i,n,a,s,o,h){Ue.call(this,e,t,r,i,n,a,s,o,h),this.needsUpdate=!0}cn.prototype=Object.create(Ue.prototype);cn.prototype.constructor=cn;cn.prototype.isCanvasTexture=!0;function un(e,t,r,i,n,a,s,o,h,c){if(c=c!==void 0?c:Mr,c!==Mr&&c!==ei)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");r===void 0&&c===Mr&&(r=Zi),r===void 0&&c===ei&&(r=Ji),Ue.call(this,null,i,n,a,s,o,c,r,h),this.image={width:e,height:t},this.magFilter=s!==void 0?s:et,this.minFilter=o!==void 0?o:et,this.flipY=!1,this.generateMipmaps=!1}un.prototype=Object.create(Ue.prototype);un.prototype.constructor=un;un.prototype.isDepthTexture=!0;function Rr(){var e=new Uint8Array(3),t=1,r=1,i=cr;Ue.call(this,null,void 0,void 0,void 0,void 0,void 0,i,void 0,void 0,void 0),this.image={data:e,width:t,height:r},this.magFilter=et,this.minFilter=et,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}Rr.prototype=Object.create(Ue.prototype);Rr.prototype.constructor=Rr;Rr.prototype.isDataTexture=!0;Rr.prototype.isCfxTexture=!0;function ln(e){$.call(this),this.type="WireframeGeometry";var t=[],r,i,n,a,s,o=[0,0],h={},c,u,l,f,d=["a","b","c"],p;if(e&&e.isGeometry){var m=e.faces;for(r=0,n=m.length;r<n;r++){var v=m[r];for(i=0;i<3;i++)u=v[d[i]],l=v[d[(i+1)%3]],o[0]=Math.min(u,l),o[1]=Math.max(u,l),f=o[0]+","+o[1],h[f]===void 0&&(h[f]={index1:o[0],index2:o[1]})}for(f in h)c=h[f],p=e.vertices[c.index1],t.push(p.x,p.y,p.z),p=e.vertices[c.index2],t.push(p.x,p.y,p.z)}else if(e&&e.isBufferGeometry){var g,_,w,y,S,R,I,C;if(p=new b,e.index!==null){for(g=e.attributes.position,_=e.index,w=e.groups,w.length===0&&(w=[{start:0,count:_.count,materialIndex:0}]),a=0,s=w.length;a<s;++a)for(y=w[a],S=y.start,R=y.count,r=S,n=S+R;r<n;r+=3)for(i=0;i<3;i++)u=_.getX(r+i),l=_.getX(r+(i+1)%3),o[0]=Math.min(u,l),o[1]=Math.max(u,l),f=o[0]+","+o[1],h[f]===void 0&&(h[f]={index1:o[0],index2:o[1]});for(f in h)c=h[f],p.fromBufferAttribute(g,c.index1),t.push(p.x,p.y,p.z),p.fromBufferAttribute(g,c.index2),t.push(p.x,p.y,p.z)}else for(g=e.attributes.position,r=0,n=g.count/3;r<n;r++)for(i=0;i<3;i++)I=3*r+i,p.fromBufferAttribute(g,I),t.push(p.x,p.y,p.z),C=3*r+(i+1)%3,p.fromBufferAttribute(g,C),t.push(p.x,p.y,p.z)}this.addAttribute("position",new Z(t,3))}ln.prototype=Object.create($.prototype);ln.prototype.constructor=ln;function fn(e,t,r){de.call(this),this.type="ParametricGeometry",this.parameters={func:e,slices:t,stacks:r},this.fromBufferGeometry(new ui(e,t,r)),this.mergeVertices()}fn.prototype=Object.create(de.prototype);fn.prototype.constructor=fn;function ui(e,t,r){$.call(this),this.type="ParametricBufferGeometry",this.parameters={func:e,slices:t,stacks:r};var i=[],n=[],a=[],s=[],o=1e-5,h=new b,c=new b,u=new b,l=new b,f=new b,d,p;e.length<3&&console.error("THREE.ParametricGeometry: Function must now modify a Vector3 as third parameter.");var m=t+1;for(d=0;d<=r;d++){var v=d/r;for(p=0;p<=t;p++){var g=p/t;e(g,v,c),n.push(c.x,c.y,c.z),g-o>=0?(e(g-o,v,u),l.subVectors(c,u)):(e(g+o,v,u),l.subVectors(u,c)),v-o>=0?(e(g,v-o,u),f.subVectors(c,u)):(e(g,v+o,u),f.subVectors(u,c)),h.crossVectors(l,f).normalize(),a.push(h.x,h.y,h.z),s.push(g,v)}}for(d=0;d<r;d++)for(p=0;p<t;p++){var _=d*m+p,w=d*m+p+1,y=(d+1)*m+p+1,S=(d+1)*m+p;i.push(_,w,S),i.push(w,y,S)}this.setIndex(i),this.addAttribute("position",new Z(n,3)),this.addAttribute("normal",new Z(a,3)),this.addAttribute("uv",new Z(s,2))}ui.prototype=Object.create($.prototype);ui.prototype.constructor=ui;function dn(e,t,r,i){de.call(this),this.type="PolyhedronGeometry",this.parameters={vertices:e,indices:t,radius:r,detail:i},this.fromBufferGeometry(new _t(e,t,r,i)),this.mergeVertices()}dn.prototype=Object.create(de.prototype);dn.prototype.constructor=dn;function _t(e,t,r,i){$.call(this),this.type="PolyhedronBufferGeometry",this.parameters={vertices:e,indices:t,radius:r,detail:i},r=r||1,i=i||0;var n=[],a=[];s(i),h(r),c(),this.addAttribute("position",new Z(n,3)),this.addAttribute("normal",new Z(n.slice(),3)),this.addAttribute("uv",new Z(a,2)),i===0?this.computeVertexNormals():this.normalizeNormals();function s(g){for(var _=new b,w=new b,y=new b,S=0;S<t.length;S+=3)f(t[S+0],_),f(t[S+1],w),f(t[S+2],y),o(_,w,y,g)}function o(g,_,w,y){var S=Math.pow(2,y),R=[],I,C;for(I=0;I<=S;I++){R[I]=[];var A=g.clone().lerp(w,I/S),O=_.clone().lerp(w,I/S),F=S-I;for(C=0;C<=F;C++)C===0&&I===S?R[I][C]=A:R[I][C]=A.clone().lerp(O,C/F)}for(I=0;I<S;I++)for(C=0;C<2*(S-I)-1;C++){var N=Math.floor(C/2);C%2===0?(l(R[I][N+1]),l(R[I+1][N]),l(R[I][N])):(l(R[I][N+1]),l(R[I+1][N+1]),l(R[I+1][N]))}}function h(g){for(var _=new b,w=0;w<n.length;w+=3)_.x=n[w+0],_.y=n[w+1],_.z=n[w+2],_.normalize().multiplyScalar(g),n[w+0]=_.x,n[w+1]=_.y,n[w+2]=_.z}function c(){for(var g=new b,_=0;_<n.length;_+=3){g.x=n[_+0],g.y=n[_+1],g.z=n[_+2];var w=m(g)/2/Math.PI+.5,y=v(g)/Math.PI+.5;a.push(w,1-y)}d(),u()}function u(){for(var g=0;g<a.length;g+=6){var _=a[g+0],w=a[g+2],y=a[g+4],S=Math.max(_,w,y),R=Math.min(_,w,y);S>.9&&R<.1&&(_<.2&&(a[g+0]+=1),w<.2&&(a[g+2]+=1),y<.2&&(a[g+4]+=1))}}function l(g){n.push(g.x,g.y,g.z)}function f(g,_){var w=g*3;_.x=e[w+0],_.y=e[w+1],_.z=e[w+2]}function d(){for(var g=new b,_=new b,w=new b,y=new b,S=new z,R=new z,I=new z,C=0,A=0;C<n.length;C+=9,A+=6){g.set(n[C+0],n[C+1],n[C+2]),_.set(n[C+3],n[C+4],n[C+5]),w.set(n[C+6],n[C+7],n[C+8]),S.set(a[A+0],a[A+1]),R.set(a[A+2],a[A+3]),I.set(a[A+4],a[A+5]),y.copy(g).add(_).add(w).divideScalar(3);var O=m(y);p(S,A+0,g,O),p(R,A+2,_,O),p(I,A+4,w,O)}}function p(g,_,w,y){y<0&&g.x===1&&(a[_]=g.x-1),w.x===0&&w.z===0&&(a[_]=y/2/Math.PI+.5)}function m(g){return Math.atan2(g.z,-g.x)}function v(g){return Math.atan2(-g.y,Math.sqrt(g.x*g.x+g.z*g.z))}}_t.prototype=Object.create($.prototype);_t.prototype.constructor=_t;function pn(e,t){de.call(this),this.type="TetrahedronGeometry",this.parameters={radius:e,detail:t},this.fromBufferGeometry(new li(e,t)),this.mergeVertices()}pn.prototype=Object.create(de.prototype);pn.prototype.constructor=pn;function li(e,t){var r=[1,1,1,-1,-1,1,-1,1,-1,1,-1,-1],i=[2,1,0,0,3,2,1,3,0,2,3,1];_t.call(this,r,i,e,t),this.type="TetrahedronBufferGeometry",this.parameters={radius:e,detail:t}}li.prototype=Object.create(_t.prototype);li.prototype.constructor=li;function mn(e,t){de.call(this),this.type="OctahedronGeometry",this.parameters={radius:e,detail:t},this.fromBufferGeometry(new Pr(e,t)),this.mergeVertices()}mn.prototype=Object.create(de.prototype);mn.prototype.constructor=mn;function Pr(e,t){var r=[1,0,0,-1,0,0,0,1,0,0,-1,0,0,0,1,0,0,-1],i=[0,2,4,0,4,3,0,3,5,0,5,2,1,2,5,1,5,3,1,3,4,1,4,2];_t.call(this,r,i,e,t),this.type="OctahedronBufferGeometry",this.parameters={radius:e,detail:t}}Pr.prototype=Object.create(_t.prototype);Pr.prototype.constructor=Pr;function vn(e,t){de.call(this),this.type="IcosahedronGeometry",this.parameters={radius:e,detail:t},this.fromBufferGeometry(new fi(e,t)),this.mergeVertices()}vn.prototype=Object.create(de.prototype);vn.prototype.constructor=vn;function fi(e,t){var r=(1+Math.sqrt(5))/2,i=[-1,r,0,1,r,0,-1,-r,0,1,-r,0,0,-1,r,0,1,r,0,-1,-r,0,1,-r,r,0,-1,r,0,1,-r,0,-1,-r,0,1],n=[0,11,5,0,5,1,0,1,7,0,7,10,0,10,11,1,5,9,5,11,4,11,10,2,10,7,6,7,1,8,3,9,4,3,4,2,3,2,6,3,6,8,3,8,9,4,9,5,2,4,11,6,2,10,8,6,7,9,8,1];_t.call(this,i,n,e,t),this.type="IcosahedronBufferGeometry",this.parameters={radius:e,detail:t}}fi.prototype=Object.create(_t.prototype);fi.prototype.constructor=fi;function gn(e,t){de.call(this),this.type="DodecahedronGeometry",this.parameters={radius:e,detail:t},this.fromBufferGeometry(new di(e,t)),this.mergeVertices()}gn.prototype=Object.create(de.prototype);gn.prototype.constructor=gn;function di(e,t){var r=(1+Math.sqrt(5))/2,i=1/r,n=[-1,-1,-1,-1,-1,1,-1,1,-1,-1,1,1,1,-1,-1,1,-1,1,1,1,-1,1,1,1,0,-i,-r,0,-i,r,0,i,-r,0,i,r,-i,-r,0,-i,r,0,i,-r,0,i,r,0,-r,0,-i,r,0,-i,-r,0,i,r,0,i],a=[3,11,7,3,7,15,3,15,13,7,19,17,7,17,6,7,6,15,17,4,8,17,8,10,17,10,6,8,0,16,8,16,2,8,2,10,0,12,1,0,1,18,0,18,16,6,10,2,6,2,13,6,13,15,2,16,18,2,18,3,2,3,13,18,1,9,18,9,11,18,11,3,4,14,12,4,12,0,4,0,8,11,9,5,11,5,19,11,19,7,19,5,14,19,14,4,19,4,17,1,12,14,1,14,5,1,5,9];_t.call(this,n,a,e,t),this.type="DodecahedronBufferGeometry",this.parameters={radius:e,detail:t}}di.prototype=Object.create(_t.prototype);di.prototype.constructor=di;function yn(e,t,r,i,n,a){de.call(this),this.type="TubeGeometry",this.parameters={path:e,tubularSegments:t,radius:r,radialSegments:i,closed:n},a!==void 0&&console.warn("THREE.TubeGeometry: taper has been removed.");var s=new pi(e,t,r,i,n);this.tangents=s.tangents,this.normals=s.normals,this.binormals=s.binormals,this.fromBufferGeometry(s),this.mergeVertices()}yn.prototype=Object.create(de.prototype);yn.prototype.constructor=yn;function pi(e,t,r,i,n){$.call(this),this.type="TubeBufferGeometry",this.parameters={path:e,tubularSegments:t,radius:r,radialSegments:i,closed:n},t=t||64,r=r||1,i=i||8,n=n||!1;var a=e.computeFrenetFrames(t,n);this.tangents=a.tangents,this.normals=a.normals,this.binormals=a.binormals;var s=new b,o=new b,h=new z,c=new b,u,l,f=[],d=[],p=[],m=[];v(),this.setIndex(m),this.addAttribute("position",new Z(f,3)),this.addAttribute("normal",new Z(d,3)),this.addAttribute("uv",new Z(p,2));function v(){for(u=0;u<t;u++)g(u);g(n===!1?t:0),w(),_()}function g(y){c=e.getPointAt(y/t,c);var S=a.normals[y],R=a.binormals[y];for(l=0;l<=i;l++){var I=l/i*Math.PI*2,C=Math.sin(I),A=-Math.cos(I);o.x=A*S.x+C*R.x,o.y=A*S.y+C*R.y,o.z=A*S.z+C*R.z,o.normalize(),d.push(o.x,o.y,o.z),s.x=c.x+r*o.x,s.y=c.y+r*o.y,s.z=c.z+r*o.z,f.push(s.x,s.y,s.z)}}function _(){for(l=1;l<=t;l++)for(u=1;u<=i;u++){var y=(i+1)*(l-1)+(u-1),S=(i+1)*l+(u-1),R=(i+1)*l+u,I=(i+1)*(l-1)+u;m.push(y,S,I),m.push(S,R,I)}}function w(){for(u=0;u<=t;u++)for(l=0;l<=i;l++)h.x=u/t,h.y=l/i,p.push(h.x,h.y)}}pi.prototype=Object.create($.prototype);pi.prototype.constructor=pi;function xn(e,t,r,i,n,a,s){de.call(this),this.type="TorusKnotGeometry",this.parameters={radius:e,tube:t,tubularSegments:r,radialSegments:i,p:n,q:a},s!==void 0&&console.warn("THREE.TorusKnotGeometry: heightScale has been deprecated. Use .scale( x, y, z ) instead."),this.fromBufferGeometry(new mi(e,t,r,i,n,a)),this.mergeVertices()}xn.prototype=Object.create(de.prototype);xn.prototype.constructor=xn;function mi(e,t,r,i,n,a){$.call(this),this.type="TorusKnotBufferGeometry",this.parameters={radius:e,tube:t,tubularSegments:r,radialSegments:i,p:n,q:a},e=e||1,t=t||.4,r=Math.floor(r)||64,i=Math.floor(i)||8,n=n||2,a=a||3;var s=[],o=[],h=[],c=[],u,l,f=new b,d=new b,p=new b,m=new b,v=new b,g=new b,_=new b;for(u=0;u<=r;++u){var w=u/r*n*Math.PI*2;for(F(w,n,a,e,p),F(w+.01,n,a,e,m),g.subVectors(m,p),_.addVectors(m,p),v.crossVectors(g,_),_.crossVectors(v,g),v.normalize(),_.normalize(),l=0;l<=i;++l){var y=l/i*Math.PI*2,S=-t*Math.cos(y),R=t*Math.sin(y);f.x=p.x+(S*_.x+R*v.x),f.y=p.y+(S*_.y+R*v.y),f.z=p.z+(S*_.z+R*v.z),o.push(f.x,f.y,f.z),d.subVectors(f,p).normalize(),h.push(d.x,d.y,d.z),c.push(u/r),c.push(l/i)}}for(l=1;l<=r;l++)for(u=1;u<=i;u++){var I=(i+1)*(l-1)+(u-1),C=(i+1)*l+(u-1),A=(i+1)*l+u,O=(i+1)*(l-1)+u;s.push(I,C,O),s.push(C,A,O)}this.setIndex(s),this.addAttribute("position",new Z(o,3)),this.addAttribute("normal",new Z(h,3)),this.addAttribute("uv",new Z(c,2));function F(N,V,k,G,J){var Y=Math.cos(N),q=Math.sin(N),E=k/V*N,T=Math.cos(E);J.x=G*(2+T)*.5*Y,J.y=G*(2+T)*q*.5,J.z=G*Math.sin(E)*.5}}mi.prototype=Object.create($.prototype);mi.prototype.constructor=mi;function _n(e,t,r,i,n){de.call(this),this.type="TorusGeometry",this.parameters={radius:e,tube:t,radialSegments:r,tubularSegments:i,arc:n},this.fromBufferGeometry(new vi(e,t,r,i,n)),this.mergeVertices()}_n.prototype=Object.create(de.prototype);_n.prototype.constructor=_n;function vi(e,t,r,i,n){$.call(this),this.type="TorusBufferGeometry",this.parameters={radius:e,tube:t,radialSegments:r,tubularSegments:i,arc:n},e=e||1,t=t||.4,r=Math.floor(r)||8,i=Math.floor(i)||6,n=n||Math.PI*2;var a=[],s=[],o=[],h=[],c=new b,u=new b,l=new b,f,d;for(f=0;f<=r;f++)for(d=0;d<=i;d++){var p=d/i*n,m=f/r*Math.PI*2;u.x=(e+t*Math.cos(m))*Math.cos(p),u.y=(e+t*Math.cos(m))*Math.sin(p),u.z=t*Math.sin(m),s.push(u.x,u.y,u.z),c.x=e*Math.cos(p),c.y=e*Math.sin(p),l.subVectors(u,c).normalize(),o.push(l.x,l.y,l.z),h.push(d/i),h.push(f/r)}for(f=1;f<=r;f++)for(d=1;d<=i;d++){var v=(i+1)*f+d-1,g=(i+1)*(f-1)+d-1,_=(i+1)*(f-1)+d,w=(i+1)*f+d;a.push(v,g,w),a.push(g,_,w)}this.setIndex(a),this.addAttribute("position",new Z(s,3)),this.addAttribute("normal",new Z(o,3)),this.addAttribute("uv",new Z(h,2))}vi.prototype=Object.create($.prototype);vi.prototype.constructor=vi;var Of={triangulate:function(e,t,r){r=r||2;var i=t&&t.length,n=i?t[0]*r:e.length,a=bo(e,0,n,r,!0),s=[];if(!a)return s;var o,h,c,u,l,f,d;if(i&&(a=Gf(e,t,a,r)),e.length>80*r){o=c=e[0],h=u=e[1];for(var p=r;p<n;p+=r)l=e[p],f=e[p+1],l<o&&(o=l),f<h&&(h=f),l>c&&(c=l),f>u&&(u=f);d=Math.max(c-o,u-h),d=d!==0?1/d:0}return yi(a,s,r,o,h,d),s}};function bo(e,t,r,i,n){var a,s;if(n===Zf(e,t,r,i)>0)for(a=t;a<r;a+=i)s=Rs(a,e[a],e[a+1],s);else for(a=r-i;a>=t;a-=i)s=Rs(a,e[a],e[a+1],s);return s&&or(s,s.next)&&(_i(s),s=s.next),s}function gi(e,t){if(!e)return e;t||(t=e);var r=e,i;do if(i=!1,!r.steiner&&(or(r,r.next)||ht(r.prev,r,r.next)===0)){if(_i(r),r=t=r.prev,r===r.next)break;i=!0}else r=r.next;while(i||r!==t);return t}function yi(e,t,r,i,n,a,s){if(e){!s&&a&&kf(e,i,n,a);for(var o=e,h,c;e.prev!==e.next;){if(h=e.prev,c=e.next,a?Uf(e,i,n,a):Ff(e)){t.push(h.i/r),t.push(e.i/r),t.push(c.i/r),_i(e),e=c.next,o=c.next;continue}if(e=c,e===o){s?s===1?(e=Bf(e,t,r),yi(e,t,r,i,n,a,2)):s===2&&Nf(e,t,r,i,n,a):yi(gi(e),t,r,i,n,a,1);break}}}}function Ff(e){var t=e.prev,r=e,i=e.next;if(ht(t,r,i)>=0)return!1;for(var n=e.next.next;n!==e.prev;){if(wn(t.x,t.y,r.x,r.y,i.x,i.y,n.x,n.y)&&ht(n.prev,n,n.next)>=0)return!1;n=n.next}return!0}function Uf(e,t,r,i){var n=e.prev,a=e,s=e.next;if(ht(n,a,s)>=0)return!1;for(var o=n.x<a.x?n.x<s.x?n.x:s.x:a.x<s.x?a.x:s.x,h=n.y<a.y?n.y<s.y?n.y:s.y:a.y<s.y?a.y:s.y,c=n.x>a.x?n.x>s.x?n.x:s.x:a.x>s.x?a.x:s.x,u=n.y>a.y?n.y>s.y?n.y:s.y:a.y>s.y?a.y:s.y,l=Ma(o,h,t,r,i),f=Ma(c,u,t,r,i),d=e.nextZ;d&&d.z<=f;){if(d!==e.prev&&d!==e.next&&wn(n.x,n.y,a.x,a.y,s.x,s.y,d.x,d.y)&&ht(d.prev,d,d.next)>=0)return!1;d=d.nextZ}for(d=e.prevZ;d&&d.z>=l;){if(d!==e.prev&&d!==e.next&&wn(n.x,n.y,a.x,a.y,s.x,s.y,d.x,d.y)&&ht(d.prev,d,d.next)>=0)return!1;d=d.prevZ}return!0}function Bf(e,t,r){var i=e;do{var n=i.prev,a=i.next.next;!or(n,a)&&Mo(n,i,i.next,a)&&xi(n,a)&&xi(a,n)&&(t.push(n.i/r),t.push(i.i/r),t.push(a.i/r),_i(i),_i(i.next),i=e=a),i=i.next}while(i!==e);return i}function Nf(e,t,r,i,n,a){var s=e;do{for(var o=s.next.next;o!==s.prev;){if(s.i!==o.i&&jf(s,o)){var h=Eo(s,o);s=gi(s,s.next),h=gi(h,h.next),yi(s,t,r,i,n,a),yi(h,t,r,i,n,a);return}o=o.next}s=s.next}while(s!==e)}function Gf(e,t,r,i){var n=[],a,s,o,h,c;for(a=0,s=t.length;a<s;a++)o=t[a]*i,h=a<s-1?t[a+1]*i:e.length,c=bo(e,o,h,i,!1),c===c.next&&(c.steiner=!0),n.push(Xf(c));for(n.sort(zf),a=0;a<n.length;a++)Hf(n[a],r),r=gi(r,r.next);return r}function zf(e,t){return e.x-t.x}function Hf(e,t){if(t=Vf(e,t),t){var r=Eo(t,e);gi(r,r.next)}}function Vf(e,t){var r=t,i=e.x,n=e.y,a=-1/0,s;do{if(n<=r.y&&n>=r.next.y&&r.next.y!==r.y){var o=r.x+(n-r.y)*(r.next.x-r.x)/(r.next.y-r.y);if(o<=i&&o>a){if(a=o,o===i){if(n===r.y)return r;if(n===r.next.y)return r.next}s=r.x<r.next.x?r:r.next}}r=r.next}while(r!==t);if(!s)return null;if(i===a)return s.prev;var h=s,c=s.x,u=s.y,l=1/0,f;for(r=s.next;r!==h;)i>=r.x&&r.x>=c&&i!==r.x&&wn(n<u?i:a,n,c,u,n<u?a:i,n,r.x,r.y)&&(f=Math.abs(n-r.y)/(i-r.x),(f<l||f===l&&r.x>s.x)&&xi(r,e)&&(s=r,l=f)),r=r.next;return s}function kf(e,t,r,i){var n=e;do n.z===null&&(n.z=Ma(n.x,n.y,t,r,i)),n.prevZ=n.prev,n.nextZ=n.next,n=n.next;while(n!==e);n.prevZ.nextZ=null,n.prevZ=null,Wf(n)}function Wf(e){var t,r,i,n,a,s,o,h,c=1;do{for(r=e,e=null,a=null,s=0;r;){for(s++,i=r,o=0,t=0;t<c&&(o++,i=i.nextZ,!!i);t++);for(h=c;o>0||h>0&&i;)o!==0&&(h===0||!i||r.z<=i.z)?(n=r,r=r.nextZ,o--):(n=i,i=i.nextZ,h--),a?a.nextZ=n:e=n,n.prevZ=a,a=n;r=i}a.nextZ=null,c*=2}while(s>1);return e}function Ma(e,t,r,i,n){return e=32767*(e-r)*n,t=32767*(t-i)*n,e=(e|e<<8)&16711935,e=(e|e<<4)&252645135,e=(e|e<<2)&858993459,e=(e|e<<1)&1431655765,t=(t|t<<8)&16711935,t=(t|t<<4)&252645135,t=(t|t<<2)&858993459,t=(t|t<<1)&1431655765,e|t<<1}function Xf(e){var t=e,r=e;do t.x<r.x&&(r=t),t=t.next;while(t!==e);return r}function wn(e,t,r,i,n,a,s,o){return(n-s)*(t-o)-(e-s)*(a-o)>=0&&(e-s)*(i-o)-(r-s)*(t-o)>=0&&(r-s)*(a-o)-(n-s)*(i-o)>=0}function jf(e,t){return e.next.i!==t.i&&e.prev.i!==t.i&&!qf(e,t)&&xi(e,t)&&xi(t,e)&&Yf(e,t)}function ht(e,t,r){return(t.y-e.y)*(r.x-t.x)-(t.x-e.x)*(r.y-t.y)}function or(e,t){return e.x===t.x&&e.y===t.y}function Mo(e,t,r,i){return or(e,t)&&or(r,i)||or(e,i)&&or(r,t)?!0:ht(e,t,r)>0!=ht(e,t,i)>0&&ht(r,i,e)>0!=ht(r,i,t)>0}function qf(e,t){var r=e;do{if(r.i!==e.i&&r.next.i!==e.i&&r.i!==t.i&&r.next.i!==t.i&&Mo(r,r.next,e,t))return!0;r=r.next}while(r!==e);return!1}function xi(e,t){return ht(e.prev,e,e.next)<0?ht(e,t,e.next)>=0&&ht(e,e.prev,t)>=0:ht(e,t,e.prev)<0||ht(e,e.next,t)<0}function Yf(e,t){var r=e,i=!1,n=(e.x+t.x)/2,a=(e.y+t.y)/2;do r.y>a!=r.next.y>a&&r.next.y!==r.y&&n<(r.next.x-r.x)*(a-r.y)/(r.next.y-r.y)+r.x&&(i=!i),r=r.next;while(r!==e);return i}function Eo(e,t){var r=new Ea(e.i,e.x,e.y),i=new Ea(t.i,t.x,t.y),n=e.next,a=t.prev;return e.next=t,t.prev=e,r.next=n,n.prev=r,i.next=r,r.prev=i,a.next=i,i.prev=a,i}function Rs(e,t,r,i){var n=new Ea(e,t,r);return i?(n.next=i.next,n.prev=i,i.next.prev=n,i.next=n):(n.prev=n,n.next=n),n}function _i(e){e.next.prev=e.prev,e.prev.next=e.next,e.prevZ&&(e.prevZ.nextZ=e.nextZ),e.nextZ&&(e.nextZ.prevZ=e.prevZ)}function Ea(e,t,r){this.i=e,this.x=t,this.y=r,this.prev=null,this.next=null,this.z=null,this.prevZ=null,this.nextZ=null,this.steiner=!1}function Zf(e,t,r,i){for(var n=0,a=t,s=r-i;a<r;a+=i)n+=(e[s]-e[a])*(e[a+1]+e[s+1]),s=a;return n}var er={area:function(e){for(var t=e.length,r=0,i=t-1,n=0;n<t;i=n++)r+=e[i].x*e[n].y-e[n].x*e[i].y;return r*.5},isClockWise:function(e){return er.area(e)<0},triangulateShape:function(e,t){var r=[],i=[],n=[];Ps(e),Cs(r,e);var a=e.length;t.forEach(Ps);for(var s=0;s<t.length;s++)i.push(a),a+=t[s].length,Cs(r,t[s]);for(var o=Of.triangulate(r,i),s=0;s<o.length;s+=3)n.push(o.slice(s,s+3));return n}};function Ps(e){var t=e.length;t>2&&e[t-1].equals(e[0])&&e.pop()}function Cs(e,t){for(var r=0;r<t.length;r++)e.push(t[r].x),e.push(t[r].y)}function Cr(e,t){de.call(this),this.type="ExtrudeGeometry",this.parameters={shapes:e,options:t},this.fromBufferGeometry(new jt(e,t)),this.mergeVertices()}Cr.prototype=Object.create(de.prototype);Cr.prototype.constructor=Cr;Cr.prototype.toJSON=function(){var e=de.prototype.toJSON.call(this),t=this.parameters.shapes,r=this.parameters.options;return To(t,r,e)};function jt(e,t){$.call(this),this.type="ExtrudeBufferGeometry",this.parameters={shapes:e,options:t},e=Array.isArray(e)?e:[e];for(var r=this,i=[],n=[],a=0,s=e.length;a<s;a++){var o=e[a];h(o)}this.addAttribute("position",new Z(i,3)),this.addAttribute("uv",new Z(n,2)),this.computeVertexNormals();function h(c){var u=[],l=t.curveSegments!==void 0?t.curveSegments:12,f=t.steps!==void 0?t.steps:1,d=t.depth!==void 0?t.depth:100,p=t.bevelEnabled!==void 0?t.bevelEnabled:!0,m=t.bevelThickness!==void 0?t.bevelThickness:6,v=t.bevelSize!==void 0?t.bevelSize:m-2,g=t.bevelSegments!==void 0?t.bevelSegments:3,_=t.extrudePath,w=t.UVGenerator!==void 0?t.UVGenerator:Jf;t.amount!==void 0&&(console.warn("THREE.ExtrudeBufferGeometry: amount has been renamed to depth."),d=t.amount);var y,S=!1,R,I,C,A;_&&(y=_.getSpacedPoints(f),S=!0,p=!1,R=_.computeFrenetFrames(f,!1),I=new b,C=new b,A=new b),p||(g=0,m=0,v=0);var O,F,N,V=c.extractPoints(l),k=V.shape,G=V.holes,J=!er.isClockWise(k);if(J)for(k=k.reverse(),F=0,N=G.length;F<N;F++)O=G[F],er.isClockWise(O)&&(G[F]=O.reverse());var Y=er.triangulateShape(k,G),q=k;for(F=0,N=G.length;F<N;F++)O=G[F],k=k.concat(O);function E(Me,Ae,D){return Ae||console.error("THREE.ExtrudeGeometry: vec does not exist"),Ae.clone().multiplyScalar(D).add(Me)}var T,U,L,Q,B,W=k.length,j,pe=Y.length;function me(Me,Ae,D){var te,ne,we,se=Me.x-Ae.x,Ee=Me.y-Ae.y,Ie=D.x-Me.x,Ce=D.y-Me.y,pt=se*se+Ee*Ee,De=se*Ce-Ee*Ie;if(Math.abs(De)>Number.EPSILON){var gt=Math.sqrt(pt),qe=Math.sqrt(Ie*Ie+Ce*Ce),Gi=Ae.x-Ee/gt,zi=Ae.y+se/gt,jn=D.x-Ce/qe,qn=D.y+Ie/qe,Hi=((jn-Gi)*Ce-(qn-zi)*Ie)/(se*Ce-Ee*Ie);te=Gi+se*Hi-Me.x,ne=zi+Ee*Hi-Me.y;var Vi=te*te+ne*ne;if(Vi<=2)return new z(te,ne);we=Math.sqrt(Vi/2)}else{var sr=!1;se>Number.EPSILON?Ie>Number.EPSILON&&(sr=!0):se<-Number.EPSILON?Ie<-Number.EPSILON&&(sr=!0):Math.sign(Ee)===Math.sign(Ce)&&(sr=!0),sr?(te=-Ee,ne=se,we=Math.sqrt(pt)):(te=se,ne=Ee,we=Math.sqrt(pt/2))}return new z(te/we,ne/we)}for(var le=[],H=0,he=q.length,Re=he-1,_e=H+1;H<he;H++,Re++,_e++)Re===he&&(Re=0),_e===he&&(_e=0),le[H]=me(q[H],q[Re],q[_e]);var rt=[],ze,Ye=le.concat();for(F=0,N=G.length;F<N;F++){for(O=G[F],ze=[],H=0,he=O.length,Re=he-1,_e=H+1;H<he;H++,Re++,_e++)Re===he&&(Re=0),_e===he&&(_e=0),ze[H]=me(O[H],O[Re],O[_e]);rt.push(ze),Ye=Ye.concat(ze)}for(T=0;T<g;T++){for(L=T/g,Q=m*Math.cos(L*Math.PI/2),U=v*Math.sin(L*Math.PI/2),H=0,he=q.length;H<he;H++)B=E(q[H],le[H],U),Ze(B.x,B.y,-Q);for(F=0,N=G.length;F<N;F++)for(O=G[F],ze=rt[F],H=0,he=O.length;H<he;H++)B=E(O[H],ze[H],U),Ze(B.x,B.y,-Q)}for(U=v,H=0;H<W;H++)B=p?E(k[H],Ye[H],U):k[H],S?(C.copy(R.normals[0]).multiplyScalar(B.x),I.copy(R.binormals[0]).multiplyScalar(B.y),A.copy(y[0]).add(C).add(I),Ze(A.x,A.y,A.z)):Ze(B.x,B.y,0);var Ke;for(Ke=1;Ke<=f;Ke++)for(H=0;H<W;H++)B=p?E(k[H],Ye[H],U):k[H],S?(C.copy(R.normals[Ke]).multiplyScalar(B.x),I.copy(R.binormals[Ke]).multiplyScalar(B.y),A.copy(y[Ke]).add(C).add(I),Ze(A.x,A.y,A.z)):Ze(B.x,B.y,d/f*Ke);for(T=g-1;T>=0;T--){for(L=T/g,Q=m*Math.cos(L*Math.PI/2),U=v*Math.sin(L*Math.PI/2),H=0,he=q.length;H<he;H++)B=E(q[H],le[H],U),Ze(B.x,B.y,d+Q);for(F=0,N=G.length;F<N;F++)for(O=G[F],ze=rt[F],H=0,he=O.length;H<he;H++)B=E(O[H],ze[H],U),S?Ze(B.x,B.y+y[f-1].y,y[f-1].x+Q):Ze(B.x,B.y,d+Q)}zt(),Lt();function zt(){var Me=i.length/3;if(p){var Ae=0,D=W*Ae;for(H=0;H<pe;H++)j=Y[H],$e(j[2]+D,j[1]+D,j[0]+D);for(Ae=f+g*2,D=W*Ae,H=0;H<pe;H++)j=Y[H],$e(j[0]+D,j[1]+D,j[2]+D)}else{for(H=0;H<pe;H++)j=Y[H],$e(j[2],j[1],j[0]);for(H=0;H<pe;H++)j=Y[H],$e(j[0]+W*f,j[1]+W*f,j[2]+W*f)}r.addGroup(Me,i.length/3-Me,0)}function Lt(){var Me=i.length/3,Ae=0;for(We(q,Ae),Ae+=q.length,F=0,N=G.length;F<N;F++)O=G[F],We(O,Ae),Ae+=O.length;r.addGroup(Me,i.length/3-Me,1)}function We(Me,Ae){var D,te;for(H=Me.length;--H>=0;){D=H,te=H-1,te<0&&(te=Me.length-1);var ne=0,we=f+g*2;for(ne=0;ne<we;ne++){var se=W*ne,Ee=W*(ne+1),Ie=Ae+D+se,Ce=Ae+te+se,pt=Ae+te+Ee,De=Ae+D+Ee;gr(Ie,Ce,pt,De)}}}function Ze(Me,Ae,D){u.push(Me),u.push(Ae),u.push(D)}function $e(Me,Ae,D){ft(Me),ft(Ae),ft(D);var te=i.length/3,ne=w.generateTopUV(r,i,te-3,te-2,te-1);dt(ne[0]),dt(ne[1]),dt(ne[2])}function gr(Me,Ae,D,te){ft(Me),ft(Ae),ft(te),ft(Ae),ft(D),ft(te);var ne=i.length/3,we=w.generateSideWallUV(r,i,ne-6,ne-3,ne-2,ne-1);dt(we[0]),dt(we[1]),dt(we[3]),dt(we[1]),dt(we[2]),dt(we[3])}function ft(Me){i.push(u[Me*3+0]),i.push(u[Me*3+1]),i.push(u[Me*3+2])}function dt(Me){n.push(Me.x),n.push(Me.y)}}}jt.prototype=Object.create($.prototype);jt.prototype.constructor=jt;jt.prototype.toJSON=function(){var e=$.prototype.toJSON.call(this),t=this.parameters.shapes,r=this.parameters.options;return To(t,r,e)};var Jf={generateTopUV:function(e,t,r,i,n){var a=t[r*3],s=t[r*3+1],o=t[i*3],h=t[i*3+1],c=t[n*3],u=t[n*3+1];return[new z(a,s),new z(o,h),new z(c,u)]},generateSideWallUV:function(e,t,r,i,n,a){var s=t[r*3],o=t[r*3+1],h=t[r*3+2],c=t[i*3],u=t[i*3+1],l=t[i*3+2],f=t[n*3],d=t[n*3+1],p=t[n*3+2],m=t[a*3],v=t[a*3+1],g=t[a*3+2];return Math.abs(o-u)<.01?[new z(s,1-h),new z(c,1-l),new z(f,1-p),new z(m,1-g)]:[new z(o,1-h),new z(u,1-l),new z(d,1-p),new z(v,1-g)]}};function To(e,t,r){if(r.shapes=[],Array.isArray(e))for(var i=0,n=e.length;i<n;i++){var a=e[i];r.shapes.push(a.uuid)}else r.shapes.push(e.uuid);return t.extrudePath!==void 0&&(r.options.extrudePath=t.extrudePath.toJSON()),r}function bn(e,t){de.call(this),this.type="TextGeometry",this.parameters={text:e,parameters:t},this.fromBufferGeometry(new wi(e,t)),this.mergeVertices()}bn.prototype=Object.create(de.prototype);bn.prototype.constructor=bn;function wi(e,t){t=t||{};var r=t.font;if(!(r&&r.isFont))return console.error("THREE.TextGeometry: font parameter is not an instance of THREE.Font."),new de;var i=r.generateShapes(e,t.size);t.depth=t.height!==void 0?t.height:50,t.bevelThickness===void 0&&(t.bevelThickness=10),t.bevelSize===void 0&&(t.bevelSize=8),t.bevelEnabled===void 0&&(t.bevelEnabled=!1),jt.call(this,i,t),this.type="TextBufferGeometry"}wi.prototype=Object.create(jt.prototype);wi.prototype.constructor=wi;function Mn(e,t,r,i,n,a,s){de.call(this),this.type="SphereGeometry",this.parameters={radius:e,widthSegments:t,heightSegments:r,phiStart:i,phiLength:n,thetaStart:a,thetaLength:s},this.fromBufferGeometry(new Ir(e,t,r,i,n,a,s)),this.mergeVertices()}Mn.prototype=Object.create(de.prototype);Mn.prototype.constructor=Mn;function Ir(e,t,r,i,n,a,s){$.call(this),this.type="SphereBufferGeometry",this.parameters={radius:e,widthSegments:t,heightSegments:r,phiStart:i,phiLength:n,thetaStart:a,thetaLength:s},e=e||1,t=Math.max(3,Math.floor(t)||8),r=Math.max(2,Math.floor(r)||6),i=i!==void 0?i:0,n=n!==void 0?n:Math.PI*2,a=a!==void 0?a:0,s=s!==void 0?s:Math.PI;var o=a+s,h,c,u=0,l=[],f=new b,d=new b,p=[],m=[],v=[],g=[];for(c=0;c<=r;c++){var _=[],w=c/r;for(h=0;h<=t;h++){var y=h/t;f.x=-e*Math.cos(i+y*n)*Math.sin(a+w*s),f.y=e*Math.cos(a+w*s),f.z=e*Math.sin(i+y*n)*Math.sin(a+w*s),m.push(f.x,f.y,f.z),d.set(f.x,f.y,f.z).normalize(),v.push(d.x,d.y,d.z),g.push(y,1-w),_.push(u++)}l.push(_)}for(c=0;c<r;c++)for(h=0;h<t;h++){var S=l[c][h+1],R=l[c][h],I=l[c+1][h],C=l[c+1][h+1];(c!==0||a>0)&&p.push(S,R,C),(c!==r-1||o<Math.PI)&&p.push(R,I,C)}this.setIndex(p),this.addAttribute("position",new Z(m,3)),this.addAttribute("normal",new Z(v,3)),this.addAttribute("uv",new Z(g,2))}Ir.prototype=Object.create($.prototype);Ir.prototype.constructor=Ir;function En(e,t,r,i,n,a){de.call(this),this.type="RingGeometry",this.parameters={innerRadius:e,outerRadius:t,thetaSegments:r,phiSegments:i,thetaStart:n,thetaLength:a},this.fromBufferGeometry(new bi(e,t,r,i,n,a)),this.mergeVertices()}En.prototype=Object.create(de.prototype);En.prototype.constructor=En;function bi(e,t,r,i,n,a){$.call(this),this.type="RingBufferGeometry",this.parameters={innerRadius:e,outerRadius:t,thetaSegments:r,phiSegments:i,thetaStart:n,thetaLength:a},e=e||.5,t=t||1,n=n!==void 0?n:0,a=a!==void 0?a:Math.PI*2,r=r!==void 0?Math.max(3,r):8,i=i!==void 0?Math.max(1,i):1;var s=[],o=[],h=[],c=[],u,l=e,f=(t-e)/i,d=new b,p=new z,m,v;for(m=0;m<=i;m++){for(v=0;v<=r;v++)u=n+v/r*a,d.x=l*Math.cos(u),d.y=l*Math.sin(u),o.push(d.x,d.y,d.z),h.push(0,0,1),p.x=(d.x/t+1)/2,p.y=(d.y/t+1)/2,c.push(p.x,p.y);l+=f}for(m=0;m<i;m++){var g=m*(r+1);for(v=0;v<r;v++){u=v+g;var _=u,w=u+r+1,y=u+r+2,S=u+1;s.push(_,w,S),s.push(w,y,S)}}this.setIndex(s),this.addAttribute("position",new Z(o,3)),this.addAttribute("normal",new Z(h,3)),this.addAttribute("uv",new Z(c,2))}bi.prototype=Object.create($.prototype);bi.prototype.constructor=bi;function Tn(e,t,r,i){de.call(this),this.type="LatheGeometry",this.parameters={points:e,segments:t,phiStart:r,phiLength:i},this.fromBufferGeometry(new Mi(e,t,r,i)),this.mergeVertices()}Tn.prototype=Object.create(de.prototype);Tn.prototype.constructor=Tn;function Mi(e,t,r,i){$.call(this),this.type="LatheBufferGeometry",this.parameters={points:e,segments:t,phiStart:r,phiLength:i},t=Math.floor(t)||12,r=r||0,i=i||Math.PI*2,i=ge.clamp(i,0,Math.PI*2);var n=[],a=[],s=[],o,h=1/t,c=new b,u=new z,l,f;for(l=0;l<=t;l++){var d=r+l*h*i,p=Math.sin(d),m=Math.cos(d);for(f=0;f<=e.length-1;f++)c.x=e[f].x*p,c.y=e[f].y,c.z=e[f].x*m,a.push(c.x,c.y,c.z),u.x=l/t,u.y=f/(e.length-1),s.push(u.x,u.y)}for(l=0;l<t;l++)for(f=0;f<e.length-1;f++){o=f+l*e.length;var v=o,g=o+e.length,_=o+e.length+1,w=o+1;n.push(v,g,w),n.push(g,_,w)}if(this.setIndex(n),this.addAttribute("position",new Z(a,3)),this.addAttribute("uv",new Z(s,2)),this.computeVertexNormals(),i===Math.PI*2){var y=this.attributes.normal.array,S=new b,R=new b,I=new b;for(o=t*e.length*3,l=0,f=0;l<e.length;l++,f+=3)S.x=y[f+0],S.y=y[f+1],S.z=y[f+2],R.x=y[o+f+0],R.y=y[o+f+1],R.z=y[o+f+2],I.addVectors(S,R).normalize(),y[f+0]=y[o+f+0]=I.x,y[f+1]=y[o+f+1]=I.y,y[f+2]=y[o+f+2]=I.z}}Mi.prototype=Object.create($.prototype);Mi.prototype.constructor=Mi;function Dr(e,t){de.call(this),this.type="ShapeGeometry",typeof t=="object"&&(console.warn("THREE.ShapeGeometry: Options parameter has been removed."),t=t.curveSegments),this.parameters={shapes:e,curveSegments:t},this.fromBufferGeometry(new Or(e,t)),this.mergeVertices()}Dr.prototype=Object.create(de.prototype);Dr.prototype.constructor=Dr;Dr.prototype.toJSON=function(){var e=de.prototype.toJSON.call(this),t=this.parameters.shapes;return So(t,e)};function Or(e,t){$.call(this),this.type="ShapeBufferGeometry",this.parameters={shapes:e,curveSegments:t},t=t||12;var r=[],i=[],n=[],a=[],s=0,o=0;if(Array.isArray(e)===!1)c(e);else for(var h=0;h<e.length;h++)c(e[h]),this.addGroup(s,o,h),s+=o,o=0;this.setIndex(r),this.addAttribute("position",new Z(i,3)),this.addAttribute("normal",new Z(n,3)),this.addAttribute("uv",new Z(a,2));function c(u){var l,f,d,p=i.length/3,m=u.extractPoints(t),v=m.shape,g=m.holes;for(er.isClockWise(v)===!1&&(v=v.reverse()),l=0,f=g.length;l<f;l++)d=g[l],er.isClockWise(d)===!0&&(g[l]=d.reverse());var _=er.triangulateShape(v,g);for(l=0,f=g.length;l<f;l++)d=g[l],v=v.concat(d);for(l=0,f=v.length;l<f;l++){var w=v[l];i.push(w.x,w.y,0),n.push(0,0,1),a.push(w.x,w.y)}for(l=0,f=_.length;l<f;l++){var y=_[l],S=y[0]+p,R=y[1]+p,I=y[2]+p;r.push(S,R,I),o+=3}}}Or.prototype=Object.create($.prototype);Or.prototype.constructor=Or;Or.prototype.toJSON=function(){var e=$.prototype.toJSON.call(this),t=this.parameters.shapes;return So(t,e)};function So(e,t){if(t.shapes=[],Array.isArray(e))for(var r=0,i=e.length;r<i;r++){var n=e[r];t.shapes.push(n.uuid)}else t.shapes.push(e.uuid);return t}function Sn(e,t){$.call(this),this.type="EdgesGeometry",this.parameters={thresholdAngle:t},t=t!==void 0?t:1;var r=[],i=Math.cos(ge.DEG2RAD*t),n=[0,0],a={},s,o,h,c=["a","b","c"],u;e.isBufferGeometry?(u=new de,u.fromBufferGeometry(e)):u=e.clone(),u.mergeVertices(),u.computeFaceNormals();for(var l=u.vertices,f=u.faces,d=0,p=f.length;d<p;d++)for(var m=f[d],v=0;v<3;v++)s=m[c[v]],o=m[c[(v+1)%3]],n[0]=Math.min(s,o),n[1]=Math.max(s,o),h=n[0]+","+n[1],a[h]===void 0?a[h]={index1:n[0],index2:n[1],face1:d,face2:void 0}:a[h].face2=d;for(h in a){var g=a[h];if(g.face2===void 0||f[g.face1].normal.dot(f[g.face2].normal)<=i){var _=l[g.index1];r.push(_.x,_.y,_.z),_=l[g.index2],r.push(_.x,_.y,_.z)}}this.addAttribute("position",new Z(r,3))}Sn.prototype=Object.create($.prototype);Sn.prototype.constructor=Sn;function Fr(e,t,r,i,n,a,s,o){de.call(this),this.type="CylinderGeometry",this.parameters={radiusTop:e,radiusBottom:t,height:r,radialSegments:i,heightSegments:n,openEnded:a,thetaStart:s,thetaLength:o},this.fromBufferGeometry(new ir(e,t,r,i,n,a,s,o)),this.mergeVertices()}Fr.prototype=Object.create(de.prototype);Fr.prototype.constructor=Fr;function ir(e,t,r,i,n,a,s,o){$.call(this),this.type="CylinderBufferGeometry",this.parameters={radiusTop:e,radiusBottom:t,height:r,radialSegments:i,heightSegments:n,openEnded:a,thetaStart:s,thetaLength:o};var h=this;e=e!==void 0?e:1,t=t!==void 0?t:1,r=r||1,i=Math.floor(i)||8,n=Math.floor(n)||1,a=a!==void 0?a:!1,s=s!==void 0?s:0,o=o!==void 0?o:Math.PI*2;var c=[],u=[],l=[],f=[],d=0,p=[],m=r/2,v=0;g(),a===!1&&(e>0&&_(!0),t>0&&_(!1)),this.setIndex(c),this.addAttribute("position",new Z(u,3)),this.addAttribute("normal",new Z(l,3)),this.addAttribute("uv",new Z(f,2));function g(){var w,y,S=new b,R=new b,I=0,C=(t-e)/r;for(y=0;y<=n;y++){var A=[],O=y/n,F=O*(t-e)+e;for(w=0;w<=i;w++){var N=w/i,V=N*o+s,k=Math.sin(V),G=Math.cos(V);R.x=F*k,R.y=-O*r+m,R.z=F*G,u.push(R.x,R.y,R.z),S.set(k,C,G).normalize(),l.push(S.x,S.y,S.z),f.push(N,1-O),A.push(d++)}p.push(A)}for(w=0;w<i;w++)for(y=0;y<n;y++){var J=p[y][w],Y=p[y+1][w],q=p[y+1][w+1],E=p[y][w+1];c.push(J,Y,E),c.push(Y,q,E),I+=6}h.addGroup(v,I,0),v+=I}function _(w){var y,S,R,I=new z,C=new b,A=0,O=w===!0?e:t,F=w===!0?1:-1;for(S=d,y=1;y<=i;y++)u.push(0,m*F,0),l.push(0,F,0),f.push(.5,.5),d++;for(R=d,y=0;y<=i;y++){var N=y/i,V=N*o+s,k=Math.cos(V),G=Math.sin(V);C.x=O*G,C.y=m*F,C.z=O*k,u.push(C.x,C.y,C.z),l.push(0,F,0),I.x=k*.5+.5,I.y=G*.5*F+.5,f.push(I.x,I.y),d++}for(y=0;y<i;y++){var J=S+y,Y=R+y;w===!0?c.push(Y,Y+1,J):c.push(Y+1,Y,J),A+=3}h.addGroup(v,A,w===!0?1:2),v+=A}}ir.prototype=Object.create($.prototype);ir.prototype.constructor=ir;function An(e,t,r,i,n,a,s){Fr.call(this,0,e,t,r,i,n,a,s),this.type="ConeGeometry",this.parameters={radius:e,height:t,radialSegments:r,heightSegments:i,openEnded:n,thetaStart:a,thetaLength:s}}An.prototype=Object.create(Fr.prototype);An.prototype.constructor=An;function Ln(e,t,r,i,n,a,s){ir.call(this,0,e,t,r,i,n,a,s),this.type="ConeBufferGeometry",this.parameters={radius:e,height:t,radialSegments:r,heightSegments:i,openEnded:n,thetaStart:a,thetaLength:s}}Ln.prototype=Object.create(ir.prototype);Ln.prototype.constructor=Ln;function Rn(e,t,r,i){de.call(this),this.type="CircleGeometry",this.parameters={radius:e,segments:t,thetaStart:r,thetaLength:i},this.fromBufferGeometry(new Ei(e,t,r,i)),this.mergeVertices()}Rn.prototype=Object.create(de.prototype);Rn.prototype.constructor=Rn;function Ei(e,t,r,i){$.call(this),this.type="CircleBufferGeometry",this.parameters={radius:e,segments:t,thetaStart:r,thetaLength:i},e=e||1,t=t!==void 0?Math.max(3,t):8,r=r!==void 0?r:0,i=i!==void 0?i:Math.PI*2;var n=[],a=[],s=[],o=[],h,c,u=new b,l=new z;for(a.push(0,0,0),s.push(0,0,1),o.push(.5,.5),c=0,h=3;c<=t;c++,h+=3){var f=r+c/t*i;u.x=e*Math.cos(f),u.y=e*Math.sin(f),a.push(u.x,u.y,u.z),s.push(0,0,1),l.x=(a[h]/e+1)/2,l.y=(a[h+1]/e+1)/2,o.push(l.x,l.y)}for(h=1;h<=t;h++)n.push(h,h+1,0);this.setIndex(n),this.addAttribute("position",new Z(a,3)),this.addAttribute("normal",new Z(s,3)),this.addAttribute("uv",new Z(o,2))}Ei.prototype=Object.create($.prototype);Ei.prototype.constructor=Ei;const mt=Object.freeze(Object.defineProperty({__proto__:null,BoxBufferGeometry:Ar,BoxGeometry:tn,CircleBufferGeometry:Ei,CircleGeometry:Rn,ConeBufferGeometry:Ln,ConeGeometry:An,CylinderBufferGeometry:ir,CylinderGeometry:Fr,DodecahedronBufferGeometry:di,DodecahedronGeometry:gn,EdgesGeometry:Sn,ExtrudeBufferGeometry:jt,ExtrudeGeometry:Cr,IcosahedronBufferGeometry:fi,IcosahedronGeometry:vn,LatheBufferGeometry:Mi,LatheGeometry:Tn,OctahedronBufferGeometry:Pr,OctahedronGeometry:mn,ParametricBufferGeometry:ui,ParametricGeometry:fn,PlaneBufferGeometry:lr,PlaneGeometry:rn,PolyhedronBufferGeometry:_t,PolyhedronGeometry:dn,RingBufferGeometry:bi,RingGeometry:En,ShapeBufferGeometry:Or,ShapeGeometry:Dr,SphereBufferGeometry:Ir,SphereGeometry:Mn,TetrahedronBufferGeometry:li,TetrahedronGeometry:pn,TextBufferGeometry:wi,TextGeometry:bn,TorusBufferGeometry:vi,TorusGeometry:_n,TorusKnotBufferGeometry:mi,TorusKnotGeometry:xn,TubeBufferGeometry:pi,TubeGeometry:yn,WireframeGeometry:ln},Symbol.toStringTag,{value:"Module"}));function Ur(e){ve.call(this),this.type="ShadowMaterial",this.color=new oe(0),this.transparent=!0,this.setValues(e)}Ur.prototype=Object.create(ve.prototype);Ur.prototype.constructor=Ur;Ur.prototype.isShadowMaterial=!0;Ur.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this};function Ti(e){xt.call(this,e),this.type="RawShaderMaterial"}Ti.prototype=Object.create(xt.prototype);Ti.prototype.constructor=Ti;Ti.prototype.isRawShaderMaterial=!0;function qt(e){ve.call(this),this.defines={STANDARD:""},this.type="MeshStandardMaterial",this.color=new oe(16777215),this.roughness=.5,this.metalness=.5,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new oe(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Wn,this.normalScale=new z(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.roughnessMap=null,this.metalnessMap=null,this.alphaMap=null,this.envMap=null,this.envMapIntensity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.setValues(e)}qt.prototype=Object.create(ve.prototype);qt.prototype.constructor=qt;qt.prototype.isMeshStandardMaterial=!0;qt.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.defines={STANDARD:""},this.color.copy(e.color),this.roughness=e.roughness,this.metalness=e.metalness,this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.emissive.copy(e.emissive),this.emissiveMap=e.emissiveMap,this.emissiveIntensity=e.emissiveIntensity,this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.roughnessMap=e.roughnessMap,this.metalnessMap=e.metalnessMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.envMapIntensity=e.envMapIntensity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this};function Br(e){qt.call(this),this.defines={PHYSICAL:""},this.type="MeshPhysicalMaterial",this.reflectivity=.5,this.clearCoat=0,this.clearCoatRoughness=0,this.setValues(e)}Br.prototype=Object.create(qt.prototype);Br.prototype.constructor=Br;Br.prototype.isMeshPhysicalMaterial=!0;Br.prototype.copy=function(e){return qt.prototype.copy.call(this,e),this.defines={PHYSICAL:""},this.reflectivity=e.reflectivity,this.clearCoat=e.clearCoat,this.clearCoatRoughness=e.clearCoatRoughness,this};function Ft(e){ve.call(this),this.type="MeshPhongMaterial",this.color=new oe(16777215),this.specular=new oe(1118481),this.shininess=30,this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new oe(0),this.emissiveIntensity=1,this.emissiveMap=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Wn,this.normalScale=new z(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=Hn,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.setValues(e)}Ft.prototype=Object.create(ve.prototype);Ft.prototype.constructor=Ft;Ft.prototype.isMeshPhongMaterial=!0;Ft.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.specular.copy(e.specular),this.shininess=e.shininess,this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.emissive.copy(e.emissive),this.emissiveMap=e.emissiveMap,this.emissiveIntensity=e.emissiveIntensity,this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.combine=e.combine,this.reflectivity=e.reflectivity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this};function Nr(e){Ft.call(this),this.defines={TOON:""},this.type="MeshToonMaterial",this.gradientMap=null,this.setValues(e)}Nr.prototype=Object.create(Ft.prototype);Nr.prototype.constructor=Nr;Nr.prototype.isMeshToonMaterial=!0;Nr.prototype.copy=function(e){return Ft.prototype.copy.call(this,e),this.gradientMap=e.gradientMap,this};function Gr(e){ve.call(this),this.type="MeshNormalMaterial",this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Wn,this.normalScale=new z(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.setValues(e)}Gr.prototype=Object.create(ve.prototype);Gr.prototype.constructor=Gr;Gr.prototype.isMeshNormalMaterial=!0;Gr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this};function zr(e){ve.call(this),this.type="MeshLambertMaterial",this.color=new oe(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.emissive=new oe(0),this.emissiveIntensity=1,this.emissiveMap=null,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=Hn,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.setValues(e)}zr.prototype=Object.create(ve.prototype);zr.prototype.constructor=zr;zr.prototype.isMeshLambertMaterial=!0;zr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.color.copy(e.color),this.map=e.map,this.lightMap=e.lightMap,this.lightMapIntensity=e.lightMapIntensity,this.aoMap=e.aoMap,this.aoMapIntensity=e.aoMapIntensity,this.emissive.copy(e.emissive),this.emissiveMap=e.emissiveMap,this.emissiveIntensity=e.emissiveIntensity,this.specularMap=e.specularMap,this.alphaMap=e.alphaMap,this.envMap=e.envMap,this.combine=e.combine,this.reflectivity=e.reflectivity,this.refractionRatio=e.refractionRatio,this.wireframe=e.wireframe,this.wireframeLinewidth=e.wireframeLinewidth,this.wireframeLinecap=e.wireframeLinecap,this.wireframeLinejoin=e.wireframeLinejoin,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this};function Hr(e){ve.call(this),this.defines={MATCAP:""},this.type="MeshMatcapMaterial",this.color=new oe(16777215),this.matcap=null,this.map=null,this.bumpMap=null,this.bumpScale=1,this.normalMap=null,this.normalMapType=Wn,this.normalScale=new z(1,1),this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.alphaMap=null,this.skinning=!1,this.morphTargets=!1,this.morphNormals=!1,this.lights=!1,this.setValues(e)}Hr.prototype=Object.create(ve.prototype);Hr.prototype.constructor=Hr;Hr.prototype.isMeshMatcapMaterial=!0;Hr.prototype.copy=function(e){return ve.prototype.copy.call(this,e),this.defines={MATCAP:""},this.color.copy(e.color),this.matcap=e.matcap,this.map=e.map,this.bumpMap=e.bumpMap,this.bumpScale=e.bumpScale,this.normalMap=e.normalMap,this.normalMapType=e.normalMapType,this.normalScale.copy(e.normalScale),this.displacementMap=e.displacementMap,this.displacementScale=e.displacementScale,this.displacementBias=e.displacementBias,this.alphaMap=e.alphaMap,this.skinning=e.skinning,this.morphTargets=e.morphTargets,this.morphNormals=e.morphNormals,this};function Vr(e){Ne.call(this),this.type="LineDashedMaterial",this.scale=1,this.dashSize=3,this.gapSize=1,this.setValues(e)}Vr.prototype=Object.create(Ne.prototype);Vr.prototype.constructor=Vr;Vr.prototype.isLineDashedMaterial=!0;Vr.prototype.copy=function(e){return Ne.prototype.copy.call(this,e),this.scale=e.scale,this.dashSize=e.dashSize,this.gapSize=e.gapSize,this};const Qf=Object.freeze(Object.defineProperty({__proto__:null,LineBasicMaterial:Ne,LineDashedMaterial:Vr,Material:ve,MeshBasicMaterial:St,MeshDepthMaterial:fr,MeshDistanceMaterial:dr,MeshLambertMaterial:zr,MeshMatcapMaterial:Hr,MeshNormalMaterial:Gr,MeshPhongMaterial:Ft,MeshPhysicalMaterial:Br,MeshStandardMaterial:qt,MeshToonMaterial:Nr,PointsMaterial:mr,RawShaderMaterial:Ti,ShaderMaterial:xt,ShadowMaterial:Ur,SpriteMaterial:pr},Symbol.toStringTag,{value:"Module"}));var ct={arraySlice:function(e,t,r){return ct.isTypedArray(e)?new e.constructor(e.subarray(t,r!==void 0?r:e.length)):e.slice(t,r)},convertArray:function(e,t,r){return!e||!r&&e.constructor===t?e:typeof t.BYTES_PER_ELEMENT=="number"?new t(e):Array.prototype.slice.call(e)},isTypedArray:function(e){return ArrayBuffer.isView(e)&&!(e instanceof DataView)},getKeyframeOrder:function(e){function t(a,s){return e[a]-e[s]}for(var r=e.length,i=new Array(r),n=0;n!==r;++n)i[n]=n;return i.sort(t),i},sortedArray:function(e,t,r){for(var i=e.length,n=new e.constructor(i),a=0,s=0;s!==i;++a)for(var o=r[a]*t,h=0;h!==t;++h)n[s++]=e[o+h];return n},flattenJSON:function(e,t,r,i){for(var n=1,a=e[0];a!==void 0&&a[i]===void 0;)a=e[n++];if(a!==void 0){var s=a[i];if(s!==void 0)if(Array.isArray(s))do s=a[i],s!==void 0&&(t.push(a.time),r.push.apply(r,s)),a=e[n++];while(a!==void 0);else if(s.toArray!==void 0)do s=a[i],s!==void 0&&(t.push(a.time),s.toArray(r,r.length)),a=e[n++];while(a!==void 0);else do s=a[i],s!==void 0&&(t.push(a.time),r.push(s)),a=e[n++];while(a!==void 0)}}};function Tt(e,t,r,i){this.parameterPositions=e,this._cachedIndex=0,this.resultBuffer=i!==void 0?i:new t.constructor(r),this.sampleValues=t,this.valueSize=r}Object.assign(Tt.prototype,{evaluate:function(e){var t=this.parameterPositions,r=this._cachedIndex,i=t[r],n=t[r-1];e:{t:{var a;r:{i:if(!(e<i)){for(var s=r+2;;){if(i===void 0){if(e<n)break i;return r=t.length,this._cachedIndex=r,this.afterEnd_(r-1,e,n)}if(r===s)break;if(n=i,i=t[++r],e<i)break t}a=t.length;break r}if(!(e>=n)){var o=t[1];e<o&&(r=2,n=o);for(var s=r-2;;){if(n===void 0)return this._cachedIndex=0,this.beforeStart_(0,e,i);if(r===s)break;if(i=n,n=t[--r-1],e>=n)break t}a=r,r=0;break r}break e}for(;r<a;){var h=r+a>>>1;e<t[h]?a=h:r=h+1}if(i=t[r],n=t[r-1],n===void 0)return this._cachedIndex=0,this.beforeStart_(0,e,i);if(i===void 0)return r=t.length,this._cachedIndex=r,this.afterEnd_(r-1,n,e)}this._cachedIndex=r,this.intervalChanged_(r,n,i)}return this.interpolate_(r,n,e,i)},settings:null,DefaultSettings_:{},getSettings_:function(){return this.settings||this.DefaultSettings_},copySampleValue_:function(e){for(var t=this.resultBuffer,r=this.sampleValues,i=this.valueSize,n=e*i,a=0;a!==i;++a)t[a]=r[n+a];return t},interpolate_:function(){throw new Error("call to abstract method")},intervalChanged_:function(){}});//!\ DECLARE ALIAS AFTER assign prototype !
Object.assign(Tt.prototype,{beforeStart_:Tt.prototype.copySampleValue_,afterEnd_:Tt.prototype.copySampleValue_});function Ta(e,t,r,i){Tt.call(this,e,t,r,i),this._weightPrev=-0,this._offsetPrev=-0,this._weightNext=-0,this._offsetNext=-0}Ta.prototype=Object.assign(Object.create(Tt.prototype),{constructor:Ta,DefaultSettings_:{endingStart:Tr,endingEnd:Tr},intervalChanged_:function(e,t,r){var i=this.parameterPositions,n=e-2,a=e+1,s=i[n],o=i[a];if(s===void 0)switch(this.getSettings_().endingStart){case wr:n=e,s=2*t-r;break;case Ki:n=i.length-2,s=t+i[n]-i[n+1];break;default:n=e,s=r}if(o===void 0)switch(this.getSettings_().endingEnd){case wr:a=e,o=2*r-t;break;case Ki:a=1,o=r+i[1]-i[0];break;default:a=e-1,o=t}var h=(r-t)*.5,c=this.valueSize;this._weightPrev=h/(t-s),this._weightNext=h/(o-r),this._offsetPrev=n*c,this._offsetNext=a*c},interpolate_:function(e,t,r,i){for(var n=this.resultBuffer,a=this.sampleValues,s=this.valueSize,o=e*s,h=o-s,c=this._offsetPrev,u=this._offsetNext,l=this._weightPrev,f=this._weightNext,d=(r-t)/(i-t),p=d*d,m=p*d,v=-l*m+2*l*p-l*d,g=(1+l)*m+(-1.5-2*l)*p+(-.5+l)*d+1,_=(-1-f)*m+(1.5+f)*p+.5*d,w=f*m-f*p,y=0;y!==s;++y)n[y]=v*a[c+y]+g*a[h+y]+_*a[o+y]+w*a[u+y];return n}});function Pn(e,t,r,i){Tt.call(this,e,t,r,i)}Pn.prototype=Object.assign(Object.create(Tt.prototype),{constructor:Pn,interpolate_:function(e,t,r,i){for(var n=this.resultBuffer,a=this.sampleValues,s=this.valueSize,o=e*s,h=o-s,c=(r-t)/(i-t),u=1-c,l=0;l!==s;++l)n[l]=a[h+l]*u+a[o+l]*c;return n}});function Sa(e,t,r,i){Tt.call(this,e,t,r,i)}Sa.prototype=Object.assign(Object.create(Tt.prototype),{constructor:Sa,interpolate_:function(e){return this.copySampleValue_(e-1)}});function at(e,t,r,i){if(e===void 0)throw new Error("THREE.KeyframeTrack: track name is undefined");if(t===void 0||t.length===0)throw new Error("THREE.KeyframeTrack: no keyframes in track named "+e);this.name=e,this.times=ct.convertArray(t,this.TimeBufferType),this.values=ct.convertArray(r,this.ValueBufferType),this.setInterpolation(i||this.DefaultInterpolation)}Object.assign(at,{toJSON:function(e){var t=e.constructor,r;if(t.toJSON!==void 0)r=t.toJSON(e);else{r={name:e.name,times:ct.convertArray(e.times,Array),values:ct.convertArray(e.values,Array)};var i=e.getInterpolation();i!==e.DefaultInterpolation&&(r.interpolation=i)}return r.type=e.ValueTypeName,r}});Object.assign(at.prototype,{constructor:at,TimeBufferType:Float32Array,ValueBufferType:Float32Array,DefaultInterpolation:Yi,InterpolantFactoryMethodDiscrete:function(e){return new Sa(this.times,this.values,this.getValueSize(),e)},InterpolantFactoryMethodLinear:function(e){return new Pn(this.times,this.values,this.getValueSize(),e)},InterpolantFactoryMethodSmooth:function(e){return new Ta(this.times,this.values,this.getValueSize(),e)},setInterpolation:function(e){var t;switch(e){case Qi:t=this.InterpolantFactoryMethodDiscrete;break;case Yi:t=this.InterpolantFactoryMethodLinear;break;case $n:t=this.InterpolantFactoryMethodSmooth;break}if(t===void 0){var r="unsupported interpolation for "+this.ValueTypeName+" keyframe track named "+this.name;if(this.createInterpolant===void 0)if(e!==this.DefaultInterpolation)this.setInterpolation(this.DefaultInterpolation);else throw new Error(r);return console.warn("THREE.KeyframeTrack:",r),this}return this.createInterpolant=t,this},getInterpolation:function(){switch(this.createInterpolant){case this.InterpolantFactoryMethodDiscrete:return Qi;case this.InterpolantFactoryMethodLinear:return Yi;case this.InterpolantFactoryMethodSmooth:return $n}},getValueSize:function(){return this.values.length/this.times.length},shift:function(e){if(e!==0)for(var t=this.times,r=0,i=t.length;r!==i;++r)t[r]+=e;return this},scale:function(e){if(e!==1)for(var t=this.times,r=0,i=t.length;r!==i;++r)t[r]*=e;return this},trim:function(e,t){for(var r=this.times,i=r.length,n=0,a=i-1;n!==i&&r[n]<e;)++n;for(;a!==-1&&r[a]>t;)--a;if(++a,n!==0||a!==i){n>=a&&(a=Math.max(a,1),n=a-1);var s=this.getValueSize();this.times=ct.arraySlice(r,n,a),this.values=ct.arraySlice(this.values,n*s,a*s)}return this},validate:function(){var e=!0,t=this.getValueSize();t-Math.floor(t)!==0&&(console.error("THREE.KeyframeTrack: Invalid value size in track.",this),e=!1);var r=this.times,i=this.values,n=r.length;n===0&&(console.error("THREE.KeyframeTrack: Track is empty.",this),e=!1);for(var a=null,s=0;s!==n;s++){var o=r[s];if(typeof o=="number"&&isNaN(o)){console.error("THREE.KeyframeTrack: Time is not a valid number.",this,s,o),e=!1;break}if(a!==null&&a>o){console.error("THREE.KeyframeTrack: Out of order keys.",this,s,o,a),e=!1;break}a=o}if(i!==void 0&&ct.isTypedArray(i))for(var s=0,h=i.length;s!==h;++s){var c=i[s];if(isNaN(c)){console.error("THREE.KeyframeTrack: Value is not a valid number.",this,s,c),e=!1;break}}return e},optimize:function(){for(var e=this.times,t=this.values,r=this.getValueSize(),i=this.getInterpolation()===$n,n=1,a=e.length-1,s=1;s<a;++s){var o=!1,h=e[s],c=e[s+1];if(h!==c&&(s!==1||h!==h[0]))if(i)o=!0;else for(var u=s*r,l=u-r,f=u+r,d=0;d!==r;++d){var p=t[u+d];if(p!==t[l+d]||p!==t[f+d]){o=!0;break}}if(o){if(s!==n){e[n]=e[s];for(var m=s*r,v=n*r,d=0;d!==r;++d)t[v+d]=t[m+d]}++n}}if(a>0){e[n]=e[a];for(var m=a*r,v=n*r,d=0;d!==r;++d)t[v+d]=t[m+d];++n}return n!==e.length&&(this.times=ct.arraySlice(e,0,n),this.values=ct.arraySlice(t,0,n*r)),this}});function Aa(e,t,r){at.call(this,e,t,r)}Aa.prototype=Object.assign(Object.create(at.prototype),{constructor:Aa,ValueTypeName:"bool",ValueBufferType:Array,DefaultInterpolation:Qi,InterpolantFactoryMethodLinear:void 0,InterpolantFactoryMethodSmooth:void 0});function La(e,t,r,i){at.call(this,e,t,r,i)}La.prototype=Object.assign(Object.create(at.prototype),{constructor:La,ValueTypeName:"color"});function Si(e,t,r,i){at.call(this,e,t,r,i)}Si.prototype=Object.assign(Object.create(at.prototype),{constructor:Si,ValueTypeName:"number"});function Ra(e,t,r,i){Tt.call(this,e,t,r,i)}Ra.prototype=Object.assign(Object.create(Tt.prototype),{constructor:Ra,interpolate_:function(e,t,r,i){for(var n=this.resultBuffer,a=this.sampleValues,s=this.valueSize,o=e*s,h=(r-t)/(i-t),c=o+s;o!==c;o+=4)Qe.slerpFlat(n,0,a,o-s,a,o,h);return n}});function Cn(e,t,r,i){at.call(this,e,t,r,i)}Cn.prototype=Object.assign(Object.create(at.prototype),{constructor:Cn,ValueTypeName:"quaternion",DefaultInterpolation:Yi,InterpolantFactoryMethodLinear:function(e){return new Ra(this.times,this.values,this.getValueSize(),e)},InterpolantFactoryMethodSmooth:void 0});function Pa(e,t,r,i){at.call(this,e,t,r,i)}Pa.prototype=Object.assign(Object.create(at.prototype),{constructor:Pa,ValueTypeName:"string",ValueBufferType:Array,DefaultInterpolation:Qi,InterpolantFactoryMethodLinear:void 0,InterpolantFactoryMethodSmooth:void 0});function Ai(e,t,r,i){at.call(this,e,t,r,i)}Ai.prototype=Object.assign(Object.create(at.prototype),{constructor:Ai,ValueTypeName:"vector"});function Ct(e,t,r){this.name=e,this.tracks=r,this.duration=t!==void 0?t:-1,this.uuid=ge.generateUUID(),this.duration<0&&this.resetDuration()}function Kf(e){switch(e.toLowerCase()){case"scalar":case"double":case"float":case"number":case"integer":return Si;case"vector":case"vector2":case"vector3":case"vector4":return Ai;case"color":return La;case"quaternion":return Cn;case"bool":case"boolean":return Aa;case"string":return Pa}throw new Error("THREE.KeyframeTrack: Unsupported typeName: "+e)}function $f(e){if(e.type===void 0)throw new Error("THREE.KeyframeTrack: track type undefined, can not parse");var t=Kf(e.type);if(e.times===void 0){var r=[],i=[];ct.flattenJSON(e.keys,r,i,"value"),e.times=r,e.values=i}return t.parse!==void 0?t.parse(e):new t(e.name,e.times,e.values,e.interpolation)}Object.assign(Ct,{parse:function(e){for(var t=[],r=e.tracks,i=1/(e.fps||1),n=0,a=r.length;n!==a;++n)t.push($f(r[n]).scale(i));return new Ct(e.name,e.duration,t)},toJSON:function(e){for(var t=[],r=e.tracks,i={name:e.name,duration:e.duration,tracks:t,uuid:e.uuid},n=0,a=r.length;n!==a;++n)t.push(at.toJSON(r[n]));return i},CreateFromMorphTargetSequence:function(e,t,r,i){for(var n=t.length,a=[],s=0;s<n;s++){var o=[],h=[];o.push((s+n-1)%n,s,(s+1)%n),h.push(0,1,0);var c=ct.getKeyframeOrder(o);o=ct.sortedArray(o,1,c),h=ct.sortedArray(h,1,c),!i&&o[0]===0&&(o.push(n),h.push(h[0])),a.push(new Si(".morphTargetInfluences["+t[s].name+"]",o,h).scale(1/r))}return new Ct(e,-1,a)},findByName:function(e,t){var r=e;if(!Array.isArray(e)){var i=e;r=i.geometry&&i.geometry.animations||i.animations}for(var n=0;n<r.length;n++)if(r[n].name===t)return r[n];return null},CreateClipsFromMorphTargetSequences:function(e,t,r){for(var i={},n=/^([\w-]*?)([\d]+)$/,a=0,s=e.length;a<s;a++){var o=e[a],h=o.name.match(n);if(h&&h.length>1){var c=h[1],u=i[c];u||(i[c]=u=[]),u.push(o)}}var l=[];for(var c in i)l.push(Ct.CreateFromMorphTargetSequence(c,i[c],t,r));return l},parseAnimation:function(e,t){if(!e)return console.error("THREE.AnimationClip: No animation in JSONLoader data."),null;for(var r=function(w,y,S,R,I){if(S.length!==0){var C=[],A=[];ct.flattenJSON(S,C,A,R),C.length!==0&&I.push(new w(y,C,A))}},i=[],n=e.name||"default",a=e.length||-1,s=e.fps||30,o=e.hierarchy||[],h=0;h<o.length;h++){var c=o[h].keys;if(!(!c||c.length===0))if(c[0].morphTargets){for(var u={},l=0;l<c.length;l++)if(c[l].morphTargets)for(var f=0;f<c[l].morphTargets.length;f++)u[c[l].morphTargets[f]]=-1;for(var d in u){for(var p=[],m=[],f=0;f!==c[l].morphTargets.length;++f){var v=c[l];p.push(v.time),m.push(v.morphTarget===d?1:0)}i.push(new Si(".morphTargetInfluence["+d+"]",p,m))}a=u.length*(s||1)}else{var g=".bones["+t[h].name+"]";r(Ai,g+".position",c,"pos",i),r(Cn,g+".quaternion",c,"rot",i),r(Ai,g+".scale",c,"scl",i)}}if(i.length===0)return null;var _=new Ct(n,a,i);return _}});Object.assign(Ct.prototype,{resetDuration:function(){for(var e=this.tracks,t=0,r=0,i=e.length;r!==i;++r){var n=this.tracks[r];t=Math.max(t,n.times[n.times.length-1])}return this.duration=t,this},trim:function(){for(var e=0;e<this.tracks.length;e++)this.tracks[e].trim(0,this.duration);return this},validate:function(){for(var e=!0,t=0;t<this.tracks.length;t++)e=e&&this.tracks[t].validate();return e},optimize:function(){for(var e=0;e<this.tracks.length;e++)this.tracks[e].optimize();return this}});var kr={enabled:!1,files:{},add:function(e,t){this.enabled!==!1&&(this.files[e]=t)},get:function(e){if(this.enabled!==!1)return this.files[e]},remove:function(e){delete this.files[e]},clear:function(){this.files={}}};function Ao(e,t,r){var i=this,n=!1,a=0,s=0,o=void 0;this.onStart=void 0,this.onLoad=e,this.onProgress=t,this.onError=r,this.itemStart=function(h){s++,n===!1&&i.onStart!==void 0&&i.onStart(h,a,s),n=!0},this.itemEnd=function(h){a++,i.onProgress!==void 0&&i.onProgress(h,a,s),a===s&&(n=!1,i.onLoad!==void 0&&i.onLoad())},this.itemError=function(h){i.onError!==void 0&&i.onError(h)},this.resolveURL=function(h){return o?o(h):h},this.setURLModifier=function(h){return o=h,this}}var Mt=new Ao,Rt={};function Jt(e){this.manager=e!==void 0?e:Mt}Object.assign(Jt.prototype,{load:function(e,t,r,i){e===void 0&&(e=""),this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);var n=this,a=kr.get(e);if(a!==void 0)return n.manager.itemStart(e),setTimeout(function(){t&&t(a),n.manager.itemEnd(e)},0),a;if(Rt[e]!==void 0){Rt[e].push({onLoad:t,onProgress:r,onError:i});return}var s=/^data:(.*?)(;base64)?,(.*)$/,o=e.match(s);if(o){var h=o[1],c=!!o[2],u=o[3];u=decodeURIComponent(u),c&&(u=atob(u));try{var l,f=(this.responseType||"").toLowerCase();switch(f){case"arraybuffer":case"blob":for(var d=new Uint8Array(u.length),p=0;p<u.length;p++)d[p]=u.charCodeAt(p);f==="blob"?l=new Blob([d.buffer],{type:h}):l=d.buffer;break;case"document":var m=new DOMParser;l=m.parseFromString(u,h);break;case"json":l=JSON.parse(u);break;default:l=u;break}setTimeout(function(){t&&t(l),n.manager.itemEnd(e)},0)}catch(_){setTimeout(function(){i&&i(_),n.manager.itemError(e),n.manager.itemEnd(e)},0)}}else{Rt[e]=[],Rt[e].push({onLoad:t,onProgress:r,onError:i});var v=new XMLHttpRequest;v.open("GET",e,!0),v.addEventListener("load",function(_){var w=this.response;kr.add(e,w);var y=Rt[e];if(delete Rt[e],this.status===200||this.status===0){this.status===0&&console.warn("THREE.FileLoader: HTTP Status 0 received.");for(var S=0,R=y.length;S<R;S++){var I=y[S];I.onLoad&&I.onLoad(w)}n.manager.itemEnd(e)}else{for(var S=0,R=y.length;S<R;S++){var I=y[S];I.onError&&I.onError(_)}n.manager.itemError(e),n.manager.itemEnd(e)}},!1),v.addEventListener("progress",function(_){for(var w=Rt[e],y=0,S=w.length;y<S;y++){var R=w[y];R.onProgress&&R.onProgress(_)}},!1),v.addEventListener("error",function(_){var w=Rt[e];delete Rt[e];for(var y=0,S=w.length;y<S;y++){var R=w[y];R.onError&&R.onError(_)}n.manager.itemError(e),n.manager.itemEnd(e)},!1),v.addEventListener("abort",function(_){var w=Rt[e];delete Rt[e];for(var y=0,S=w.length;y<S;y++){var R=w[y];R.onError&&R.onError(_)}n.manager.itemError(e),n.manager.itemEnd(e)},!1),this.responseType!==void 0&&(v.responseType=this.responseType),this.withCredentials!==void 0&&(v.withCredentials=this.withCredentials),v.overrideMimeType&&v.overrideMimeType(this.mimeType!==void 0?this.mimeType:"text/plain");for(var g in this.requestHeader)v.setRequestHeader(g,this.requestHeader[g]);v.send(null)}return n.manager.itemStart(e),v},setPath:function(e){return this.path=e,this},setResponseType:function(e){return this.responseType=e,this},setWithCredentials:function(e){return this.withCredentials=e,this},setMimeType:function(e){return this.mimeType=e,this},setRequestHeader:function(e){return this.requestHeader=e,this}});function ed(e){this.manager=e!==void 0?e:Mt}Object.assign(ed.prototype,{load:function(e,t,r,i){var n=this,a=new Jt(n.manager);a.setPath(n.path),a.load(e,function(s){t(n.parse(JSON.parse(s)))},r,i)},parse:function(e,t){for(var r=[],i=0;i<e.length;i++){var n=Ct.parse(e[i]);r.push(n)}t(r)},setPath:function(e){return this.path=e,this}});function td(e){this.manager=e!==void 0?e:Mt,this._parser=null}Object.assign(td.prototype,{load:function(e,t,r,i){var n=this,a=[],s=new ci;s.image=a;var o=new Jt(this.manager);o.setPath(this.path),o.setResponseType("arraybuffer");function h(f){o.load(e[f],function(d){var p=n._parser(d,!0);a[f]={width:p.width,height:p.height,format:p.format,mipmaps:p.mipmaps},c+=1,c===6&&(p.mipmapCount===1&&(s.minFilter=it),s.format=p.format,s.needsUpdate=!0,t&&t(s))},r,i)}if(Array.isArray(e))for(var c=0,u=0,l=e.length;u<l;++u)h(u);else o.load(e,function(f){var d=n._parser(f,!0);if(d.isCubemap)for(var p=d.mipmaps.length/d.mipmapCount,m=0;m<p;m++){a[m]={mipmaps:[]};for(var v=0;v<d.mipmapCount;v++)a[m].mipmaps.push(d.mipmaps[m*d.mipmapCount+v]),a[m].format=d.format,a[m].width=d.width,a[m].height=d.height}else s.image.width=d.width,s.image.height=d.height,s.mipmaps=d.mipmaps;d.mipmapCount===1&&(s.minFilter=it),s.format=d.format,s.needsUpdate=!0,t&&t(s)},r,i);return s},setPath:function(e){return this.path=e,this}});function rd(e){this.manager=e!==void 0?e:Mt,this._parser=null}Object.assign(rd.prototype,{load:function(e,t,r,i){var n=this,a=new Sr,s=new Jt(this.manager);return s.setResponseType("arraybuffer"),s.setPath(this.path),s.load(e,function(o){var h=n._parser(o);h&&(h.image!==void 0?a.image=h.image:h.data!==void 0&&(a.image.width=h.width,a.image.height=h.height,a.image.data=h.data),a.wrapS=h.wrapS!==void 0?h.wrapS:Et,a.wrapT=h.wrapT!==void 0?h.wrapT:Et,a.magFilter=h.magFilter!==void 0?h.magFilter:it,a.minFilter=h.minFilter!==void 0?h.minFilter:Vn,a.anisotropy=h.anisotropy!==void 0?h.anisotropy:1,h.format!==void 0&&(a.format=h.format),h.type!==void 0&&(a.type=h.type),h.mipmaps!==void 0&&(a.mipmaps=h.mipmaps),h.mipmapCount===1&&(a.minFilter=it),a.needsUpdate=!0,t&&t(a,h))},r,i),a},setPath:function(e){return this.path=e,this}});function Xn(e){this.manager=e!==void 0?e:Mt}Object.assign(Xn.prototype,{crossOrigin:"anonymous",load:function(e,t,r,i){e===void 0&&(e=""),this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);var n=this,a=kr.get(e);if(a!==void 0)return n.manager.itemStart(e),setTimeout(function(){t&&t(a),n.manager.itemEnd(e)},0),a;var s=document.createElementNS("http://www.w3.org/1999/xhtml","img");function o(){s.removeEventListener("load",o,!1),s.removeEventListener("error",h,!1),kr.add(e,this),t&&t(this),n.manager.itemEnd(e)}function h(c){s.removeEventListener("load",o,!1),s.removeEventListener("error",h,!1),i&&i(c),n.manager.itemError(e),n.manager.itemEnd(e)}return s.addEventListener("load",o,!1),s.addEventListener("error",h,!1),e.substr(0,5)!=="data:"&&this.crossOrigin!==void 0&&(s.crossOrigin=this.crossOrigin),n.manager.itemStart(e),s.src=e,s},setCrossOrigin:function(e){return this.crossOrigin=e,this},setPath:function(e){return this.path=e,this}});function Lo(e){this.manager=e!==void 0?e:Mt}Object.assign(Lo.prototype,{crossOrigin:"anonymous",load:function(e,t,r,i){var n=new rr,a=new Xn(this.manager);a.setCrossOrigin(this.crossOrigin),a.setPath(this.path);var s=0;function o(c){a.load(e[c],function(u){n.images[c]=u,s++,s===6&&(n.needsUpdate=!0,t&&t(n))},void 0,i)}for(var h=0;h<e.length;++h)o(h);return n},setCrossOrigin:function(e){return this.crossOrigin=e,this},setPath:function(e){return this.path=e,this}});function $a(e){this.manager=e!==void 0?e:Mt}Object.assign($a.prototype,{crossOrigin:"anonymous",load:function(e,t,r,i){var n=new Ue,a=new Xn(this.manager);return a.setCrossOrigin(this.crossOrigin),a.setPath(this.path),a.load(e,function(s){n.image=s;var o=e.search(/\.jpe?g($|\?)/i)>0||e.search(/^data\:image\/jpeg/)===0;n.format=o?cr:Wt,n.needsUpdate=!0,t!==void 0&&t(n)},r,i),n},setCrossOrigin:function(e){return this.crossOrigin=e,this},setPath:function(e){return this.path=e,this}});function ce(){this.type="Curve",this.arcLengthDivisions=200}Object.assign(ce.prototype,{getPoint:function(){return console.warn("THREE.Curve: .getPoint() not implemented."),null},getPointAt:function(e,t){var r=this.getUtoTmapping(e);return this.getPoint(r,t)},getPoints:function(e){e===void 0&&(e=5);for(var t=[],r=0;r<=e;r++)t.push(this.getPoint(r/e));return t},getSpacedPoints:function(e){e===void 0&&(e=5);for(var t=[],r=0;r<=e;r++)t.push(this.getPointAt(r/e));return t},getLength:function(){var e=this.getLengths();return e[e.length-1]},getLengths:function(e){if(e===void 0&&(e=this.arcLengthDivisions),this.cacheArcLengths&&this.cacheArcLengths.length===e+1&&!this.needsUpdate)return this.cacheArcLengths;this.needsUpdate=!1;var t=[],r,i=this.getPoint(0),n,a=0;for(t.push(0),n=1;n<=e;n++)r=this.getPoint(n/e),a+=r.distanceTo(i),t.push(a),i=r;return this.cacheArcLengths=t,t},updateArcLengths:function(){this.needsUpdate=!0,this.getLengths()},getUtoTmapping:function(e,t){var r=this.getLengths(),i=0,n=r.length,a;t?a=t:a=e*r[n-1];for(var s=0,o=n-1,h;s<=o;)if(i=Math.floor(s+(o-s)/2),h=r[i]-a,h<0)s=i+1;else if(h>0)o=i-1;else{o=i;break}if(i=o,r[i]===a)return i/(n-1);var c=r[i],u=r[i+1],l=u-c,f=(a-c)/l,d=(i+f)/(n-1);return d},getTangent:function(e){var t=1e-4,r=e-t,i=e+t;r<0&&(r=0),i>1&&(i=1);var n=this.getPoint(r),a=this.getPoint(i),s=a.clone().sub(n);return s.normalize()},getTangentAt:function(e){var t=this.getUtoTmapping(e);return this.getTangent(t)},computeFrenetFrames:function(e,t){var r=new b,i=[],n=[],a=[],s=new b,o=new fe,h,c,u;for(h=0;h<=e;h++)c=h/e,i[h]=this.getTangentAt(c),i[h].normalize();n[0]=new b,a[0]=new b;var l=Number.MAX_VALUE,f=Math.abs(i[0].x),d=Math.abs(i[0].y),p=Math.abs(i[0].z);for(f<=l&&(l=f,r.set(1,0,0)),d<=l&&(l=d,r.set(0,1,0)),p<=l&&r.set(0,0,1),s.crossVectors(i[0],r).normalize(),n[0].crossVectors(i[0],s),a[0].crossVectors(i[0],n[0]),h=1;h<=e;h++)n[h]=n[h-1].clone(),a[h]=a[h-1].clone(),s.crossVectors(i[h-1],i[h]),s.length()>Number.EPSILON&&(s.normalize(),u=Math.acos(ge.clamp(i[h-1].dot(i[h]),-1,1)),n[h].applyMatrix4(o.makeRotationAxis(s,u))),a[h].crossVectors(i[h],n[h]);if(t===!0)for(u=Math.acos(ge.clamp(n[0].dot(n[e]),-1,1)),u/=e,i[0].dot(s.crossVectors(n[0],n[e]))>0&&(u=-u),h=1;h<=e;h++)n[h].applyMatrix4(o.makeRotationAxis(i[h],u*h)),a[h].crossVectors(i[h],n[h]);return{tangents:i,normals:n,binormals:a}},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.arcLengthDivisions=e.arcLengthDivisions,this},toJSON:function(){var e={metadata:{version:4.5,type:"Curve",generator:"Curve.toJSON"}};return e.arcLengthDivisions=this.arcLengthDivisions,e.type=this.type,e},fromJSON:function(e){return this.arcLengthDivisions=e.arcLengthDivisions,this}});function At(e,t,r,i,n,a,s,o){ce.call(this),this.type="EllipseCurve",this.aX=e||0,this.aY=t||0,this.xRadius=r||1,this.yRadius=i||1,this.aStartAngle=n||0,this.aEndAngle=a||2*Math.PI,this.aClockwise=s||!1,this.aRotation=o||0}At.prototype=Object.create(ce.prototype);At.prototype.constructor=At;At.prototype.isEllipseCurve=!0;At.prototype.getPoint=function(e,t){for(var r=t||new z,i=Math.PI*2,n=this.aEndAngle-this.aStartAngle,a=Math.abs(n)<Number.EPSILON;n<0;)n+=i;for(;n>i;)n-=i;n<Number.EPSILON&&(a?n=0:n=i),this.aClockwise===!0&&!a&&(n===i?n=-i:n=n-i);var s=this.aStartAngle+e*n,o=this.aX+this.xRadius*Math.cos(s),h=this.aY+this.yRadius*Math.sin(s);if(this.aRotation!==0){var c=Math.cos(this.aRotation),u=Math.sin(this.aRotation),l=o-this.aX,f=h-this.aY;o=l*c-f*u+this.aX,h=l*u+f*c+this.aY}return r.set(o,h)};At.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.aX=e.aX,this.aY=e.aY,this.xRadius=e.xRadius,this.yRadius=e.yRadius,this.aStartAngle=e.aStartAngle,this.aEndAngle=e.aEndAngle,this.aClockwise=e.aClockwise,this.aRotation=e.aRotation,this};At.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.aX=this.aX,e.aY=this.aY,e.xRadius=this.xRadius,e.yRadius=this.yRadius,e.aStartAngle=this.aStartAngle,e.aEndAngle=this.aEndAngle,e.aClockwise=this.aClockwise,e.aRotation=this.aRotation,e};At.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.aX=e.aX,this.aY=e.aY,this.xRadius=e.xRadius,this.yRadius=e.yRadius,this.aStartAngle=e.aStartAngle,this.aEndAngle=e.aEndAngle,this.aClockwise=e.aClockwise,this.aRotation=e.aRotation,this};function Li(e,t,r,i,n,a){At.call(this,e,t,r,r,i,n,a),this.type="ArcCurve"}Li.prototype=Object.create(At.prototype);Li.prototype.constructor=Li;Li.prototype.isArcCurve=!0;function es(){var e=0,t=0,r=0,i=0;function n(a,s,o,h){e=a,t=o,r=-3*a+3*s-2*o-h,i=2*a-2*s+o+h}return{initCatmullRom:function(a,s,o,h,c){n(s,o,c*(o-a),c*(h-s))},initNonuniformCatmullRom:function(a,s,o,h,c,u,l){var f=(s-a)/c-(o-a)/(c+u)+(o-s)/u,d=(o-s)/u-(h-s)/(u+l)+(h-o)/l;f*=u,d*=u,n(s,o,f,d)},calc:function(a){var s=a*a,o=s*a;return e+t*a+r*s+i*o}}}var Xi=new b,ta=new es,ra=new es,ia=new es;function wt(e,t,r,i){ce.call(this),this.type="CatmullRomCurve3",this.points=e||[],this.closed=t||!1,this.curveType=r||"centripetal",this.tension=i||.5}wt.prototype=Object.create(ce.prototype);wt.prototype.constructor=wt;wt.prototype.isCatmullRomCurve3=!0;wt.prototype.getPoint=function(e,t){var r=t||new b,i=this.points,n=i.length,a=(n-(this.closed?0:1))*e,s=Math.floor(a),o=a-s;this.closed?s+=s>0?0:(Math.floor(Math.abs(s)/n)+1)*n:o===0&&s===n-1&&(s=n-2,o=1);var h,c,u,l;if(this.closed||s>0?h=i[(s-1)%n]:(Xi.subVectors(i[0],i[1]).add(i[0]),h=Xi),c=i[s%n],u=i[(s+1)%n],this.closed||s+2<n?l=i[(s+2)%n]:(Xi.subVectors(i[n-1],i[n-2]).add(i[n-1]),l=Xi),this.curveType==="centripetal"||this.curveType==="chordal"){var f=this.curveType==="chordal"?.5:.25,d=Math.pow(h.distanceToSquared(c),f),p=Math.pow(c.distanceToSquared(u),f),m=Math.pow(u.distanceToSquared(l),f);p<1e-4&&(p=1),d<1e-4&&(d=p),m<1e-4&&(m=p),ta.initNonuniformCatmullRom(h.x,c.x,u.x,l.x,d,p,m),ra.initNonuniformCatmullRom(h.y,c.y,u.y,l.y,d,p,m),ia.initNonuniformCatmullRom(h.z,c.z,u.z,l.z,d,p,m)}else this.curveType==="catmullrom"&&(ta.initCatmullRom(h.x,c.x,u.x,l.x,this.tension),ra.initCatmullRom(h.y,c.y,u.y,l.y,this.tension),ia.initCatmullRom(h.z,c.z,u.z,l.z,this.tension));return r.set(ta.calc(o),ra.calc(o),ia.calc(o)),r};wt.prototype.copy=function(e){ce.prototype.copy.call(this,e),this.points=[];for(var t=0,r=e.points.length;t<r;t++){var i=e.points[t];this.points.push(i.clone())}return this.closed=e.closed,this.curveType=e.curveType,this.tension=e.tension,this};wt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);e.points=[];for(var t=0,r=this.points.length;t<r;t++){var i=this.points[t];e.points.push(i.toArray())}return e.closed=this.closed,e.curveType=this.curveType,e.tension=this.tension,e};wt.prototype.fromJSON=function(e){ce.prototype.fromJSON.call(this,e),this.points=[];for(var t=0,r=e.points.length;t<r;t++){var i=e.points[t];this.points.push(new b().fromArray(i))}return this.closed=e.closed,this.curveType=e.curveType,this.tension=e.tension,this};function Is(e,t,r,i,n){var a=(i-t)*.5,s=(n-r)*.5,o=e*e,h=e*o;return(2*r-2*i+a+s)*h+(-3*r+3*i-2*a-s)*o+a*e+r}function id(e,t){var r=1-e;return r*r*t}function nd(e,t){return 2*(1-e)*e*t}function ad(e,t){return e*e*t}function Qr(e,t,r,i){return id(e,t)+nd(e,r)+ad(e,i)}function sd(e,t){var r=1-e;return r*r*r*t}function od(e,t){var r=1-e;return 3*r*r*e*t}function hd(e,t){return 3*(1-e)*e*e*t}function cd(e,t){return e*e*e*t}function Kr(e,t,r,i,n){return sd(e,t)+od(e,r)+hd(e,i)+cd(e,n)}function Ut(e,t,r,i){ce.call(this),this.type="CubicBezierCurve",this.v0=e||new z,this.v1=t||new z,this.v2=r||new z,this.v3=i||new z}Ut.prototype=Object.create(ce.prototype);Ut.prototype.constructor=Ut;Ut.prototype.isCubicBezierCurve=!0;Ut.prototype.getPoint=function(e,t){var r=t||new z,i=this.v0,n=this.v1,a=this.v2,s=this.v3;return r.set(Kr(e,i.x,n.x,a.x,s.x),Kr(e,i.y,n.y,a.y,s.y)),r};Ut.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v0.copy(e.v0),this.v1.copy(e.v1),this.v2.copy(e.v2),this.v3.copy(e.v3),this};Ut.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v0=this.v0.toArray(),e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e.v3=this.v3.toArray(),e};Ut.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v0.fromArray(e.v0),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this.v3.fromArray(e.v3),this};function Yt(e,t,r,i){ce.call(this),this.type="CubicBezierCurve3",this.v0=e||new b,this.v1=t||new b,this.v2=r||new b,this.v3=i||new b}Yt.prototype=Object.create(ce.prototype);Yt.prototype.constructor=Yt;Yt.prototype.isCubicBezierCurve3=!0;Yt.prototype.getPoint=function(e,t){var r=t||new b,i=this.v0,n=this.v1,a=this.v2,s=this.v3;return r.set(Kr(e,i.x,n.x,a.x,s.x),Kr(e,i.y,n.y,a.y,s.y),Kr(e,i.z,n.z,a.z,s.z)),r};Yt.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v0.copy(e.v0),this.v1.copy(e.v1),this.v2.copy(e.v2),this.v3.copy(e.v3),this};Yt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v0=this.v0.toArray(),e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e.v3=this.v3.toArray(),e};Yt.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v0.fromArray(e.v0),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this.v3.fromArray(e.v3),this};function bt(e,t){ce.call(this),this.type="LineCurve",this.v1=e||new z,this.v2=t||new z}bt.prototype=Object.create(ce.prototype);bt.prototype.constructor=bt;bt.prototype.isLineCurve=!0;bt.prototype.getPoint=function(e,t){var r=t||new z;return e===1?r.copy(this.v2):(r.copy(this.v2).sub(this.v1),r.multiplyScalar(e).add(this.v1)),r};bt.prototype.getPointAt=function(e,t){return this.getPoint(e,t)};bt.prototype.getTangent=function(){var e=this.v2.clone().sub(this.v1);return e.normalize()};bt.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v1.copy(e.v1),this.v2.copy(e.v2),this};bt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e};bt.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this};function Bt(e,t){ce.call(this),this.type="LineCurve3",this.v1=e||new b,this.v2=t||new b}Bt.prototype=Object.create(ce.prototype);Bt.prototype.constructor=Bt;Bt.prototype.isLineCurve3=!0;Bt.prototype.getPoint=function(e,t){var r=t||new b;return e===1?r.copy(this.v2):(r.copy(this.v2).sub(this.v1),r.multiplyScalar(e).add(this.v1)),r};Bt.prototype.getPointAt=function(e,t){return this.getPoint(e,t)};Bt.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v1.copy(e.v1),this.v2.copy(e.v2),this};Bt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e};Bt.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this};function Nt(e,t,r){ce.call(this),this.type="QuadraticBezierCurve",this.v0=e||new z,this.v1=t||new z,this.v2=r||new z}Nt.prototype=Object.create(ce.prototype);Nt.prototype.constructor=Nt;Nt.prototype.isQuadraticBezierCurve=!0;Nt.prototype.getPoint=function(e,t){var r=t||new z,i=this.v0,n=this.v1,a=this.v2;return r.set(Qr(e,i.x,n.x,a.x),Qr(e,i.y,n.y,a.y)),r};Nt.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v0.copy(e.v0),this.v1.copy(e.v1),this.v2.copy(e.v2),this};Nt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v0=this.v0.toArray(),e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e};Nt.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v0.fromArray(e.v0),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this};function Zt(e,t,r){ce.call(this),this.type="QuadraticBezierCurve3",this.v0=e||new b,this.v1=t||new b,this.v2=r||new b}Zt.prototype=Object.create(ce.prototype);Zt.prototype.constructor=Zt;Zt.prototype.isQuadraticBezierCurve3=!0;Zt.prototype.getPoint=function(e,t){var r=t||new b,i=this.v0,n=this.v1,a=this.v2;return r.set(Qr(e,i.x,n.x,a.x),Qr(e,i.y,n.y,a.y),Qr(e,i.z,n.z,a.z)),r};Zt.prototype.copy=function(e){return ce.prototype.copy.call(this,e),this.v0.copy(e.v0),this.v1.copy(e.v1),this.v2.copy(e.v2),this};Zt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);return e.v0=this.v0.toArray(),e.v1=this.v1.toArray(),e.v2=this.v2.toArray(),e};Zt.prototype.fromJSON=function(e){return ce.prototype.fromJSON.call(this,e),this.v0.fromArray(e.v0),this.v1.fromArray(e.v1),this.v2.fromArray(e.v2),this};function Gt(e){ce.call(this),this.type="SplineCurve",this.points=e||[]}Gt.prototype=Object.create(ce.prototype);Gt.prototype.constructor=Gt;Gt.prototype.isSplineCurve=!0;Gt.prototype.getPoint=function(e,t){var r=t||new z,i=this.points,n=(i.length-1)*e,a=Math.floor(n),s=n-a,o=i[a===0?a:a-1],h=i[a],c=i[a>i.length-2?i.length-1:a+1],u=i[a>i.length-3?i.length-1:a+2];return r.set(Is(s,o.x,h.x,c.x,u.x),Is(s,o.y,h.y,c.y,u.y)),r};Gt.prototype.copy=function(e){ce.prototype.copy.call(this,e),this.points=[];for(var t=0,r=e.points.length;t<r;t++){var i=e.points[t];this.points.push(i.clone())}return this};Gt.prototype.toJSON=function(){var e=ce.prototype.toJSON.call(this);e.points=[];for(var t=0,r=this.points.length;t<r;t++){var i=this.points[t];e.points.push(i.toArray())}return e};Gt.prototype.fromJSON=function(e){ce.prototype.fromJSON.call(this,e),this.points=[];for(var t=0,r=e.points.length;t<r;t++){var i=e.points[t];this.points.push(new z().fromArray(i))}return this};const Ro=Object.freeze(Object.defineProperty({__proto__:null,ArcCurve:Li,CatmullRomCurve3:wt,CubicBezierCurve:Ut,CubicBezierCurve3:Yt,EllipseCurve:At,LineCurve:bt,LineCurve3:Bt,QuadraticBezierCurve:Nt,QuadraticBezierCurve3:Zt,SplineCurve:Gt},Symbol.toStringTag,{value:"Module"}));function Kt(){ce.call(this),this.type="CurvePath",this.curves=[],this.autoClose=!1}Kt.prototype=Object.assign(Object.create(ce.prototype),{constructor:Kt,add:function(e){this.curves.push(e)},closePath:function(){var e=this.curves[0].getPoint(0),t=this.curves[this.curves.length-1].getPoint(1);e.equals(t)||this.curves.push(new bt(t,e))},getPoint:function(e){for(var t=e*this.getLength(),r=this.getCurveLengths(),i=0;i<r.length;){if(r[i]>=t){var n=r[i]-t,a=this.curves[i],s=a.getLength(),o=s===0?0:1-n/s;return a.getPointAt(o)}i++}return null},getLength:function(){var e=this.getCurveLengths();return e[e.length-1]},updateArcLengths:function(){this.needsUpdate=!0,this.cacheLengths=null,this.getCurveLengths()},getCurveLengths:function(){if(this.cacheLengths&&this.cacheLengths.length===this.curves.length)return this.cacheLengths;for(var e=[],t=0,r=0,i=this.curves.length;r<i;r++)t+=this.curves[r].getLength(),e.push(t);return this.cacheLengths=e,e},getSpacedPoints:function(e){e===void 0&&(e=40);for(var t=[],r=0;r<=e;r++)t.push(this.getPoint(r/e));return this.autoClose&&t.push(t[0]),t},getPoints:function(e){e=e||12;for(var t=[],r,i=0,n=this.curves;i<n.length;i++)for(var a=n[i],s=a&&a.isEllipseCurve?e*2:a&&(a.isLineCurve||a.isLineCurve3)?1:a&&a.isSplineCurve?e*a.points.length:e,o=a.getPoints(s),h=0;h<o.length;h++){var c=o[h];r&&r.equals(c)||(t.push(c),r=c)}return this.autoClose&&t.length>1&&!t[t.length-1].equals(t[0])&&t.push(t[0]),t},copy:function(e){ce.prototype.copy.call(this,e),this.curves=[];for(var t=0,r=e.curves.length;t<r;t++){var i=e.curves[t];this.curves.push(i.clone())}return this.autoClose=e.autoClose,this},toJSON:function(){var e=ce.prototype.toJSON.call(this);e.autoClose=this.autoClose,e.curves=[];for(var t=0,r=this.curves.length;t<r;t++){var i=this.curves[t];e.curves.push(i.toJSON())}return e},fromJSON:function(e){ce.prototype.fromJSON.call(this,e),this.autoClose=e.autoClose,this.curves=[];for(var t=0,r=e.curves.length;t<r;t++){var i=e.curves[t];this.curves.push(new Ro[i.type]().fromJSON(i))}return this}});function It(e){Kt.call(this),this.type="Path",this.currentPoint=new z,e&&this.setFromPoints(e)}It.prototype=Object.assign(Object.create(Kt.prototype),{constructor:It,setFromPoints:function(e){this.moveTo(e[0].x,e[0].y);for(var t=1,r=e.length;t<r;t++)this.lineTo(e[t].x,e[t].y)},moveTo:function(e,t){this.currentPoint.set(e,t)},lineTo:function(e,t){var r=new bt(this.currentPoint.clone(),new z(e,t));this.curves.push(r),this.currentPoint.set(e,t)},quadraticCurveTo:function(e,t,r,i){var n=new Nt(this.currentPoint.clone(),new z(e,t),new z(r,i));this.curves.push(n),this.currentPoint.set(r,i)},bezierCurveTo:function(e,t,r,i,n,a){var s=new Ut(this.currentPoint.clone(),new z(e,t),new z(r,i),new z(n,a));this.curves.push(s),this.currentPoint.set(n,a)},splineThru:function(e){var t=[this.currentPoint.clone()].concat(e),r=new Gt(t);this.curves.push(r),this.currentPoint.copy(e[e.length-1])},arc:function(e,t,r,i,n,a){var s=this.currentPoint.x,o=this.currentPoint.y;this.absarc(e+s,t+o,r,i,n,a)},absarc:function(e,t,r,i,n,a){this.absellipse(e,t,r,r,i,n,a)},ellipse:function(e,t,r,i,n,a,s,o){var h=this.currentPoint.x,c=this.currentPoint.y;this.absellipse(e+h,t+c,r,i,n,a,s,o)},absellipse:function(e,t,r,i,n,a,s,o){var h=new At(e,t,r,i,n,a,s,o);if(this.curves.length>0){var c=h.getPoint(0);c.equals(this.currentPoint)||this.lineTo(c.x,c.y)}this.curves.push(h);var u=h.getPoint(1);this.currentPoint.copy(u)},copy:function(e){return Kt.prototype.copy.call(this,e),this.currentPoint.copy(e.currentPoint),this},toJSON:function(){var e=Kt.prototype.toJSON.call(this);return e.currentPoint=this.currentPoint.toArray(),e},fromJSON:function(e){return Kt.prototype.fromJSON.call(this,e),this.currentPoint.fromArray(e.currentPoint),this}});function hr(e){It.call(this,e),this.uuid=ge.generateUUID(),this.type="Shape",this.holes=[]}hr.prototype=Object.assign(Object.create(It.prototype),{constructor:hr,getPointsHoles:function(e){for(var t=[],r=0,i=this.holes.length;r<i;r++)t[r]=this.holes[r].getPoints(e);return t},extractPoints:function(e){return{shape:this.getPoints(e),holes:this.getPointsHoles(e)}},copy:function(e){It.prototype.copy.call(this,e),this.holes=[];for(var t=0,r=e.holes.length;t<r;t++){var i=e.holes[t];this.holes.push(i.clone())}return this},toJSON:function(){var e=It.prototype.toJSON.call(this);e.uuid=this.uuid,e.holes=[];for(var t=0,r=this.holes.length;t<r;t++){var i=this.holes[t];e.holes.push(i.toJSON())}return e},fromJSON:function(e){It.prototype.fromJSON.call(this,e),this.uuid=e.uuid,this.holes=[];for(var t=0,r=e.holes.length;t<r;t++){var i=e.holes[t];this.holes.push(new It().fromJSON(i))}return this}});function ke(e,t){K.call(this),this.type="Light",this.color=new oe(e),this.intensity=t!==void 0?t:1,this.receiveShadow=void 0}ke.prototype=Object.assign(Object.create(K.prototype),{constructor:ke,isLight:!0,copy:function(e){return K.prototype.copy.call(this,e),this.color.copy(e.color),this.intensity=e.intensity,this},toJSON:function(e){var t=K.prototype.toJSON.call(this,e);return t.object.color=this.color.getHex(),t.object.intensity=this.intensity,this.groundColor!==void 0&&(t.object.groundColor=this.groundColor.getHex()),this.distance!==void 0&&(t.object.distance=this.distance),this.angle!==void 0&&(t.object.angle=this.angle),this.decay!==void 0&&(t.object.decay=this.decay),this.penumbra!==void 0&&(t.object.penumbra=this.penumbra),this.shadow!==void 0&&(t.object.shadow=this.shadow.toJSON()),t}});function Ca(e,t,r){ke.call(this,e,r),this.type="HemisphereLight",this.castShadow=void 0,this.position.copy(K.DefaultUp),this.updateMatrix(),this.groundColor=new oe(t)}Ca.prototype=Object.assign(Object.create(ke.prototype),{constructor:Ca,isHemisphereLight:!0,copy:function(e){return ke.prototype.copy.call(this,e),this.groundColor.copy(e.groundColor),this}});function Yr(e){this.camera=e,this.bias=0,this.radius=1,this.mapSize=new z(512,512),this.map=null,this.matrix=new fe}Object.assign(Yr.prototype,{copy:function(e){return this.camera=e.camera.clone(),this.bias=e.bias,this.radius=e.radius,this.mapSize.copy(e.mapSize),this},clone:function(){return new this.constructor().copy(this)},toJSON:function(){var e={};return this.bias!==0&&(e.bias=this.bias),this.radius!==1&&(e.radius=this.radius),(this.mapSize.x!==512||this.mapSize.y!==512)&&(e.mapSize=this.mapSize.toArray()),e.camera=this.camera.toJSON(!1).object,delete e.camera.matrix,e}});function Ia(){Yr.call(this,new je(50,1,.5,500))}Ia.prototype=Object.assign(Object.create(Yr.prototype),{constructor:Ia,isSpotLightShadow:!0,update:function(e){var t=this.camera,r=ge.RAD2DEG*2*e.angle,i=this.mapSize.width/this.mapSize.height,n=e.distance||t.far;(r!==t.fov||i!==t.aspect||n!==t.far)&&(t.fov=r,t.aspect=i,t.far=n,t.updateProjectionMatrix())}});function Da(e,t,r,i,n,a){ke.call(this,e,t),this.type="SpotLight",this.position.copy(K.DefaultUp),this.updateMatrix(),this.target=new K,Object.defineProperty(this,"power",{get:function(){return this.intensity*Math.PI},set:function(s){this.intensity=s/Math.PI}}),this.distance=r!==void 0?r:0,this.angle=i!==void 0?i:Math.PI/3,this.penumbra=n!==void 0?n:0,this.decay=a!==void 0?a:1,this.shadow=new Ia}Da.prototype=Object.assign(Object.create(ke.prototype),{constructor:Da,isSpotLight:!0,copy:function(e){return ke.prototype.copy.call(this,e),this.distance=e.distance,this.angle=e.angle,this.penumbra=e.penumbra,this.decay=e.decay,this.target=e.target.clone(),this.shadow=e.shadow.clone(),this}});function Oa(e,t,r,i){ke.call(this,e,t),this.type="PointLight",Object.defineProperty(this,"power",{get:function(){return this.intensity*4*Math.PI},set:function(n){this.intensity=n/(4*Math.PI)}}),this.distance=r!==void 0?r:0,this.decay=i!==void 0?i:1,this.shadow=new Yr(new je(90,1,.5,500))}Oa.prototype=Object.assign(Object.create(ke.prototype),{constructor:Oa,isPointLight:!0,copy:function(e){return ke.prototype.copy.call(this,e),this.distance=e.distance,this.decay=e.decay,this.shadow=e.shadow.clone(),this}});function Ri(e,t,r,i,n,a){Xt.call(this),this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=e!==void 0?e:-1,this.right=t!==void 0?t:1,this.top=r!==void 0?r:1,this.bottom=i!==void 0?i:-1,this.near=n!==void 0?n:.1,this.far=a!==void 0?a:2e3,this.updateProjectionMatrix()}Ri.prototype=Object.assign(Object.create(Xt.prototype),{constructor:Ri,isOrthographicCamera:!0,copy:function(e,t){return Xt.prototype.copy.call(this,e,t),this.left=e.left,this.right=e.right,this.top=e.top,this.bottom=e.bottom,this.near=e.near,this.far=e.far,this.zoom=e.zoom,this.view=e.view===null?null:Object.assign({},e.view),this},setViewOffset:function(e,t,r,i,n,a){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=e,this.view.fullHeight=t,this.view.offsetX=r,this.view.offsetY=i,this.view.width=n,this.view.height=a,this.updateProjectionMatrix()},clearViewOffset:function(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()},updateProjectionMatrix:function(){var e=(this.right-this.left)/(2*this.zoom),t=(this.top-this.bottom)/(2*this.zoom),r=(this.right+this.left)/2,i=(this.top+this.bottom)/2,n=r-e,a=r+e,s=i+t,o=i-t;if(this.view!==null&&this.view.enabled){var h=this.zoom/(this.view.width/this.view.fullWidth),c=this.zoom/(this.view.height/this.view.fullHeight),u=(this.right-this.left)/this.view.width,l=(this.top-this.bottom)/this.view.height;n+=u*(this.view.offsetX/h),a=n+u*(this.view.width/h),s-=l*(this.view.offsetY/c),o=s-l*(this.view.height/c)}this.projectionMatrix.makeOrthographic(n,a,s,o,this.near,this.far),this.projectionMatrixInverse.getInverse(this.projectionMatrix)},toJSON:function(e){var t=K.prototype.toJSON.call(this,e);return t.object.zoom=this.zoom,t.object.left=this.left,t.object.right=this.right,t.object.top=this.top,t.object.bottom=this.bottom,t.object.near=this.near,t.object.far=this.far,this.view!==null&&(t.object.view=Object.assign({},this.view)),t}});function Fa(){Yr.call(this,new Ri(-5,5,5,-5,.5,500))}Fa.prototype=Object.assign(Object.create(Yr.prototype),{constructor:Fa});function Ua(e,t){ke.call(this,e,t),this.type="DirectionalLight",this.position.copy(K.DefaultUp),this.updateMatrix(),this.target=new K,this.shadow=new Fa}Ua.prototype=Object.assign(Object.create(ke.prototype),{constructor:Ua,isDirectionalLight:!0,copy:function(e){return ke.prototype.copy.call(this,e),this.target=e.target.clone(),this.shadow=e.shadow.clone(),this}});function Ba(e,t){ke.call(this,e,t),this.type="AmbientLight",this.castShadow=void 0}Ba.prototype=Object.assign(Object.create(ke.prototype),{constructor:Ba,isAmbientLight:!0});function Na(e,t,r,i){ke.call(this,e,t),this.type="RectAreaLight",this.width=r!==void 0?r:10,this.height=i!==void 0?i:10}Na.prototype=Object.assign(Object.create(ke.prototype),{constructor:Na,isRectAreaLight:!0,copy:function(e){return ke.prototype.copy.call(this,e),this.width=e.width,this.height=e.height,this},toJSON:function(e){var t=ke.prototype.toJSON.call(this,e);return t.object.width=this.width,t.object.height=this.height,t}});function ts(e){this.manager=e!==void 0?e:Mt,this.textures={}}Object.assign(ts.prototype,{load:function(e,t,r,i){var n=this,a=new Jt(n.manager);a.setPath(n.path),a.load(e,function(s){t(n.parse(JSON.parse(s)))},r,i)},parse:function(e){var t=this.textures;function r(h){return t[h]===void 0&&console.warn("THREE.MaterialLoader: Undefined texture",h),t[h]}var i=new Qf[e.type];if(e.uuid!==void 0&&(i.uuid=e.uuid),e.name!==void 0&&(i.name=e.name),e.color!==void 0&&i.color.setHex(e.color),e.roughness!==void 0&&(i.roughness=e.roughness),e.metalness!==void 0&&(i.metalness=e.metalness),e.emissive!==void 0&&i.emissive.setHex(e.emissive),e.specular!==void 0&&i.specular.setHex(e.specular),e.shininess!==void 0&&(i.shininess=e.shininess),e.clearCoat!==void 0&&(i.clearCoat=e.clearCoat),e.clearCoatRoughness!==void 0&&(i.clearCoatRoughness=e.clearCoatRoughness),e.vertexColors!==void 0&&(i.vertexColors=e.vertexColors),e.fog!==void 0&&(i.fog=e.fog),e.flatShading!==void 0&&(i.flatShading=e.flatShading),e.blending!==void 0&&(i.blending=e.blending),e.combine!==void 0&&(i.combine=e.combine),e.side!==void 0&&(i.side=e.side),e.opacity!==void 0&&(i.opacity=e.opacity),e.transparent!==void 0&&(i.transparent=e.transparent),e.alphaTest!==void 0&&(i.alphaTest=e.alphaTest),e.depthTest!==void 0&&(i.depthTest=e.depthTest),e.depthWrite!==void 0&&(i.depthWrite=e.depthWrite),e.colorWrite!==void 0&&(i.colorWrite=e.colorWrite),e.wireframe!==void 0&&(i.wireframe=e.wireframe),e.wireframeLinewidth!==void 0&&(i.wireframeLinewidth=e.wireframeLinewidth),e.wireframeLinecap!==void 0&&(i.wireframeLinecap=e.wireframeLinecap),e.wireframeLinejoin!==void 0&&(i.wireframeLinejoin=e.wireframeLinejoin),e.rotation!==void 0&&(i.rotation=e.rotation),e.linewidth!==1&&(i.linewidth=e.linewidth),e.dashSize!==void 0&&(i.dashSize=e.dashSize),e.gapSize!==void 0&&(i.gapSize=e.gapSize),e.scale!==void 0&&(i.scale=e.scale),e.polygonOffset!==void 0&&(i.polygonOffset=e.polygonOffset),e.polygonOffsetFactor!==void 0&&(i.polygonOffsetFactor=e.polygonOffsetFactor),e.polygonOffsetUnits!==void 0&&(i.polygonOffsetUnits=e.polygonOffsetUnits),e.skinning!==void 0&&(i.skinning=e.skinning),e.morphTargets!==void 0&&(i.morphTargets=e.morphTargets),e.dithering!==void 0&&(i.dithering=e.dithering),e.visible!==void 0&&(i.visible=e.visible),e.userData!==void 0&&(i.userData=e.userData),e.uniforms!==void 0)for(var n in e.uniforms){var a=e.uniforms[n];switch(i.uniforms[n]={},a.type){case"t":i.uniforms[n].value=r(a.value);break;case"c":i.uniforms[n].value=new oe().setHex(a.value);break;case"v2":i.uniforms[n].value=new z().fromArray(a.value);break;case"v3":i.uniforms[n].value=new b().fromArray(a.value);break;case"v4":i.uniforms[n].value=new Fe().fromArray(a.value);break;case"m3":i.uniforms[n].value=new nt().fromArray(a.value);case"m4":i.uniforms[n].value=new fe().fromArray(a.value);break;default:i.uniforms[n].value=a.value}}if(e.defines!==void 0&&(i.defines=e.defines),e.vertexShader!==void 0&&(i.vertexShader=e.vertexShader),e.fragmentShader!==void 0&&(i.fragmentShader=e.fragmentShader),e.extensions!==void 0)for(var s in e.extensions)i.extensions[s]=e.extensions[s];if(e.shading!==void 0&&(i.flatShading=e.shading===1),e.size!==void 0&&(i.size=e.size),e.sizeAttenuation!==void 0&&(i.sizeAttenuation=e.sizeAttenuation),e.map!==void 0&&(i.map=r(e.map)),e.alphaMap!==void 0&&(i.alphaMap=r(e.alphaMap),i.transparent=!0),e.bumpMap!==void 0&&(i.bumpMap=r(e.bumpMap)),e.bumpScale!==void 0&&(i.bumpScale=e.bumpScale),e.normalMap!==void 0&&(i.normalMap=r(e.normalMap)),e.normalMapType!==void 0&&(i.normalMapType=e.normalMapType),e.normalScale!==void 0){var o=e.normalScale;Array.isArray(o)===!1&&(o=[o,o]),i.normalScale=new z().fromArray(o)}return e.displacementMap!==void 0&&(i.displacementMap=r(e.displacementMap)),e.displacementScale!==void 0&&(i.displacementScale=e.displacementScale),e.displacementBias!==void 0&&(i.displacementBias=e.displacementBias),e.roughnessMap!==void 0&&(i.roughnessMap=r(e.roughnessMap)),e.metalnessMap!==void 0&&(i.metalnessMap=r(e.metalnessMap)),e.emissiveMap!==void 0&&(i.emissiveMap=r(e.emissiveMap)),e.emissiveIntensity!==void 0&&(i.emissiveIntensity=e.emissiveIntensity),e.specularMap!==void 0&&(i.specularMap=r(e.specularMap)),e.envMap!==void 0&&(i.envMap=r(e.envMap)),e.envMapIntensity!==void 0&&(i.envMapIntensity=e.envMapIntensity),e.reflectivity!==void 0&&(i.reflectivity=e.reflectivity),e.lightMap!==void 0&&(i.lightMap=r(e.lightMap)),e.lightMapIntensity!==void 0&&(i.lightMapIntensity=e.lightMapIntensity),e.aoMap!==void 0&&(i.aoMap=r(e.aoMap)),e.aoMapIntensity!==void 0&&(i.aoMapIntensity=e.aoMapIntensity),e.gradientMap!==void 0&&(i.gradientMap=r(e.gradientMap)),i},setPath:function(e){return this.path=e,this},setTextures:function(e){return this.textures=e,this}});var Po={decodeText:function(e){if(typeof TextDecoder<"u")return new TextDecoder().decode(e);for(var t="",r=0,i=e.length;r<i;r++)t+=String.fromCharCode(e[r]);return decodeURIComponent(escape(t))},extractUrlBase:function(e){var t=e.lastIndexOf("/");return t===-1?"./":e.substr(0,t+1)}};function Co(e){this.manager=e!==void 0?e:Mt}Object.assign(Co.prototype,{load:function(e,t,r,i){var n=this,a=new Jt(n.manager);a.setPath(n.path),a.load(e,function(s){t(n.parse(JSON.parse(s)))},r,i)},parse:function(e){var t=new $,r=e.data.index;if(r!==void 0){var i=new Ds[r.type](r.array);t.setIndex(new xe(i,1))}var n=e.data.attributes;for(var a in n){var s=n[a],i=new Ds[s.type](s.array);t.addAttribute(a,new xe(i,s.itemSize,s.normalized))}var o=e.data.groups||e.data.drawcalls||e.data.offsets;if(o!==void 0)for(var h=0,c=o.length;h!==c;++h){var u=o[h];t.addGroup(u.start,u.count,u.materialIndex)}var l=e.data.boundingSphere;if(l!==void 0){var f=new b;l.center!==void 0&&f.fromArray(l.center),t.boundingSphere=new Ot(f,l.radius)}return e.name&&(t.name=e.name),e.userData&&(t.userData=e.userData),t},setPath:function(e){return this.path=e,this}});var Ds={Int8Array,Uint8Array,Uint8ClampedArray:typeof Uint8ClampedArray<"u"?Uint8ClampedArray:Uint8Array,Int16Array,Uint16Array,Int32Array,Uint32Array,Float32Array,Float64Array};function Io(e){this.manager=e!==void 0?e:Mt,this.resourcePath=""}Object.assign(Io.prototype,{crossOrigin:"anonymous",load:function(e,t,r,i){var n=this,a=this.path===void 0?Po.extractUrlBase(e):this.path;this.resourcePath=this.resourcePath||a;var s=new Jt(n.manager);s.setPath(this.path),s.load(e,function(o){var h=null;try{h=JSON.parse(o)}catch(u){i!==void 0&&i(u),console.error("THREE:ObjectLoader: Can't parse "+e+".",u.message);return}var c=h.metadata;if(c===void 0||c.type===void 0||c.type.toLowerCase()==="geometry"){console.error("THREE.ObjectLoader: Can't load "+e);return}n.parse(h,t)},r,i)},setPath:function(e){return this.path=e,this},setResourcePath:function(e){return this.resourcePath=e,this},setCrossOrigin:function(e){return this.crossOrigin=e,this},parse:function(e,t){var r=this.parseShape(e.shapes),i=this.parseGeometries(e.geometries,r),n=this.parseImages(e.images,function(){t!==void 0&&t(o)}),a=this.parseTextures(e.textures,n),s=this.parseMaterials(e.materials,a),o=this.parseObject(e.object,i,s);return e.animations&&(o.animations=this.parseAnimations(e.animations)),(e.images===void 0||e.images.length===0)&&t!==void 0&&t(o),o},parseShape:function(e){var t={};if(e!==void 0)for(var r=0,i=e.length;r<i;r++){var n=new hr().fromJSON(e[r]);t[n.uuid]=n}return t},parseGeometries:function(e,t){var r={};if(e!==void 0)for(var i=new Co,n=0,a=e.length;n<a;n++){var s,o=e[n];switch(o.type){case"PlaneGeometry":case"PlaneBufferGeometry":s=new mt[o.type](o.width,o.height,o.widthSegments,o.heightSegments);break;case"BoxGeometry":case"BoxBufferGeometry":case"CubeGeometry":s=new mt[o.type](o.width,o.height,o.depth,o.widthSegments,o.heightSegments,o.depthSegments);break;case"CircleGeometry":case"CircleBufferGeometry":s=new mt[o.type](o.radius,o.segments,o.thetaStart,o.thetaLength);break;case"CylinderGeometry":case"CylinderBufferGeometry":s=new mt[o.type](o.radiusTop,o.radiusBottom,o.height,o.radialSegments,o.heightSegments,o.openEnded,o.thetaStart,o.thetaLength);break;case"ConeGeometry":case"ConeBufferGeometry":s=new mt[o.type](o.radius,o.height,o.radialSegments,o.heightSegments,o.openEnded,o.thetaStart,o.thetaLength);break;case"SphereGeometry":case"SphereBufferGeometry":s=new mt[o.type](o.radius,o.widthSegments,o.heightSegments,o.phiStart,o.phiLength,o.thetaStart,o.thetaLength);break;case"DodecahedronGeometry":case"DodecahedronBufferGeometry":case"IcosahedronGeometry":case"IcosahedronBufferGeometry":case"OctahedronGeometry":case"OctahedronBufferGeometry":case"TetrahedronGeometry":case"TetrahedronBufferGeometry":s=new mt[o.type](o.radius,o.detail);break;case"RingGeometry":case"RingBufferGeometry":s=new mt[o.type](o.innerRadius,o.outerRadius,o.thetaSegments,o.phiSegments,o.thetaStart,o.thetaLength);break;case"TorusGeometry":case"TorusBufferGeometry":s=new mt[o.type](o.radius,o.tube,o.radialSegments,o.tubularSegments,o.arc);break;case"TorusKnotGeometry":case"TorusKnotBufferGeometry":s=new mt[o.type](o.radius,o.tube,o.tubularSegments,o.radialSegments,o.p,o.q);break;case"LatheGeometry":case"LatheBufferGeometry":s=new mt[o.type](o.points,o.segments,o.phiStart,o.phiLength);break;case"PolyhedronGeometry":case"PolyhedronBufferGeometry":s=new mt[o.type](o.vertices,o.indices,o.radius,o.details);break;case"ShapeGeometry":case"ShapeBufferGeometry":for(var l=[],h=0,c=o.shapes.length;h<c;h++){var u=t[o.shapes[h]];l.push(u)}s=new mt[o.type](l,o.curveSegments);break;case"ExtrudeGeometry":case"ExtrudeBufferGeometry":for(var l=[],h=0,c=o.shapes.length;h<c;h++){var u=t[o.shapes[h]];l.push(u)}var f=o.options.extrudePath;f!==void 0&&(o.options.extrudePath=new Ro[f.type]().fromJSON(f)),s=new mt[o.type](l,o.options);break;case"BufferGeometry":s=i.parse(o);break;case"Geometry":if("THREE"in window&&"LegacyJSONLoader"in THREE){var d=new THREE.LegacyJSONLoader;s=d.parse(o,this.resourcePath).geometry}else console.error('THREE.ObjectLoader: You have to import LegacyJSONLoader in order load geometry data of type "Geometry".');break;default:console.warn('THREE.ObjectLoader: Unsupported geometry type "'+o.type+'"');continue}s.uuid=o.uuid,o.name!==void 0&&(s.name=o.name),s.isBufferGeometry===!0&&o.userData!==void 0&&(s.userData=o.userData),r[o.uuid]=s}return r},parseMaterials:function(e,t){var r={},i={};if(e!==void 0){var n=new ts;n.setTextures(t);for(var a=0,s=e.length;a<s;a++){var o=e[a];if(o.type==="MultiMaterial"){for(var h=[],c=0;c<o.materials.length;c++){var u=o.materials[c];r[u.uuid]===void 0&&(r[u.uuid]=n.parse(u)),h.push(r[u.uuid])}i[o.uuid]=h}else i[o.uuid]=n.parse(o),r[o.uuid]=i[o.uuid]}}return i},parseAnimations:function(e){for(var t=[],r=0;r<e.length;r++){var i=e[r],n=Ct.parse(i);i.uuid!==void 0&&(n.uuid=i.uuid),t.push(n)}return t},parseImages:function(e,t){var r=this,i={};function n(m){return r.manager.itemStart(m),s.load(m,function(){r.manager.itemEnd(m)},void 0,function(){r.manager.itemError(m),r.manager.itemEnd(m)})}if(e!==void 0&&e.length>0){var a=new Ao(t),s=new Xn(a);s.setCrossOrigin(this.crossOrigin);for(var o=0,h=e.length;o<h;o++){var c=e[o],u=c.url;if(Array.isArray(u)){i[c.uuid]=[];for(var l=0,f=u.length;l<f;l++){var d=u[l],p=/^(\/\/)|([a-z]+:(\/\/)?)/i.test(d)?d:r.resourcePath+d;i[c.uuid].push(n(p))}}else{var p=/^(\/\/)|([a-z]+:(\/\/)?)/i.test(c.url)?c.url:r.resourcePath+c.url;i[c.uuid]=n(p)}}}return i},parseTextures:function(e,t){function r(h,c){return typeof h=="number"?h:(console.warn("THREE.ObjectLoader.parseTexture: Constant should be in numeric form.",h),c[h])}var i={};if(e!==void 0)for(var n=0,a=e.length;n<a;n++){var s=e[n];s.image===void 0&&console.warn('THREE.ObjectLoader: No "image" specified for',s.uuid),t[s.image]===void 0&&console.warn("THREE.ObjectLoader: Undefined image",s.image);var o;Array.isArray(t[s.image])?o=new rr(t[s.image]):o=new Ue(t[s.image]),o.needsUpdate=!0,o.uuid=s.uuid,s.name!==void 0&&(o.name=s.name),s.mapping!==void 0&&(o.mapping=r(s.mapping,ud)),s.offset!==void 0&&o.offset.fromArray(s.offset),s.repeat!==void 0&&o.repeat.fromArray(s.repeat),s.center!==void 0&&o.center.fromArray(s.center),s.rotation!==void 0&&(o.rotation=s.rotation),s.wrap!==void 0&&(o.wrapS=r(s.wrap[0],Os),o.wrapT=r(s.wrap[1],Os)),s.format!==void 0&&(o.format=s.format),s.type!==void 0&&(o.type=s.type),s.encoding!==void 0&&(o.encoding=s.encoding),s.minFilter!==void 0&&(o.minFilter=r(s.minFilter,Fs)),s.magFilter!==void 0&&(o.magFilter=r(s.magFilter,Fs)),s.anisotropy!==void 0&&(o.anisotropy=s.anisotropy),s.flipY!==void 0&&(o.flipY=s.flipY),s.premultiplyAlpha!==void 0&&(o.premultiplyAlpha=s.premultiplyAlpha),s.unpackAlignment!==void 0&&(o.unpackAlignment=s.unpackAlignment),i[s.uuid]=o}return i},parseObject:function(e,t,r){var i;function n(p){return t[p]===void 0&&console.warn("THREE.ObjectLoader: Undefined geometry",p),t[p]}function a(p){if(p!==void 0){if(Array.isArray(p)){for(var m=[],v=0,g=p.length;v<g;v++){var _=p[v];r[_]===void 0&&console.warn("THREE.ObjectLoader: Undefined material",_),m.push(r[_])}return m}return r[p]===void 0&&console.warn("THREE.ObjectLoader: Undefined material",p),r[p]}}switch(e.type){case"Scene":i=new an,e.background!==void 0&&Number.isInteger(e.background)&&(i.background=new oe(e.background)),e.fog!==void 0&&(e.fog.type==="Fog"?i.fog=new hi(e.fog.color,e.fog.near,e.fog.far):e.fog.type==="FogExp2"&&(i.fog=new oi(e.fog.color,e.fog.density)));break;case"PerspectiveCamera":i=new je(e.fov,e.aspect,e.near,e.far),e.focus!==void 0&&(i.focus=e.focus),e.zoom!==void 0&&(i.zoom=e.zoom),e.filmGauge!==void 0&&(i.filmGauge=e.filmGauge),e.filmOffset!==void 0&&(i.filmOffset=e.filmOffset),e.view!==void 0&&(i.view=Object.assign({},e.view));break;case"OrthographicCamera":i=new Ri(e.left,e.right,e.top,e.bottom,e.near,e.far),e.zoom!==void 0&&(i.zoom=e.zoom),e.view!==void 0&&(i.view=Object.assign({},e.view));break;case"AmbientLight":i=new Ba(e.color,e.intensity);break;case"DirectionalLight":i=new Ua(e.color,e.intensity);break;case"PointLight":i=new Oa(e.color,e.intensity,e.distance,e.decay);break;case"RectAreaLight":i=new Na(e.color,e.intensity,e.width,e.height);break;case"SpotLight":i=new Da(e.color,e.intensity,e.distance,e.angle,e.penumbra,e.decay);break;case"HemisphereLight":i=new Ca(e.color,e.groundColor,e.intensity);break;case"SkinnedMesh":console.warn("THREE.ObjectLoader.parseObject() does not support SkinnedMesh yet.");case"Mesh":var s=n(e.geometry),o=a(e.material);s.bones&&s.bones.length>0?i=new hn(s,o):i=new lt(s,o);break;case"LOD":i=new on;break;case"Line":i=new vt(n(e.geometry),a(e.material),e.mode);break;case"LineLoop":i=new wa(n(e.geometry),a(e.material));break;case"LineSegments":i=new Ge(n(e.geometry),a(e.material));break;case"PointCloud":case"Points":i=new ba(n(e.geometry),a(e.material));break;case"Sprite":i=new xa(a(e.material));break;case"Group":i=new si;break;default:i=new K}if(i.uuid=e.uuid,e.name!==void 0&&(i.name=e.name),e.matrix!==void 0?(i.matrix.fromArray(e.matrix),e.matrixAutoUpdate!==void 0&&(i.matrixAutoUpdate=e.matrixAutoUpdate),i.matrixAutoUpdate&&i.matrix.decompose(i.position,i.quaternion,i.scale)):(e.position!==void 0&&i.position.fromArray(e.position),e.rotation!==void 0&&i.rotation.fromArray(e.rotation),e.quaternion!==void 0&&i.quaternion.fromArray(e.quaternion),e.scale!==void 0&&i.scale.fromArray(e.scale)),e.castShadow!==void 0&&(i.castShadow=e.castShadow),e.receiveShadow!==void 0&&(i.receiveShadow=e.receiveShadow),e.shadow&&(e.shadow.bias!==void 0&&(i.shadow.bias=e.shadow.bias),e.shadow.radius!==void 0&&(i.shadow.radius=e.shadow.radius),e.shadow.mapSize!==void 0&&i.shadow.mapSize.fromArray(e.shadow.mapSize),e.shadow.camera!==void 0&&(i.shadow.camera=this.parseObject(e.shadow.camera))),e.visible!==void 0&&(i.visible=e.visible),e.frustumCulled!==void 0&&(i.frustumCulled=e.frustumCulled),e.renderOrder!==void 0&&(i.renderOrder=e.renderOrder),e.userData!==void 0&&(i.userData=e.userData),e.layers!==void 0&&(i.layers.mask=e.layers),e.children!==void 0)for(var h=e.children,c=0;c<h.length;c++)i.add(this.parseObject(h[c],t,r));if(e.type==="LOD")for(var u=e.levels,l=0;l<u.length;l++){var f=u[l],d=i.getObjectByProperty("uuid",f.object);d!==void 0&&i.addLevel(d,f.distance)}return i}});var ud={UVMapping:ka,CubeReflectionMapping:Wa,CubeRefractionMapping:ua,EquirectangularReflectionMapping:$s,EquirectangularRefractionMapping:la,SphericalReflectionMapping:eo,CubeUVReflectionMapping:Xa,CubeUVRefractionMapping:ja},Os={RepeatWrapping:Qt,ClampToEdgeWrapping:Et,MirroredRepeatWrapping:Er},Fs={NearestFilter:et,NearestMipMapNearestFilter:qa,NearestMipMapLinearFilter:Ya,LinearFilter:it,LinearMipMapNearestFilter:to,LinearMipMapLinearFilter:Vn};function Us(e){typeof createImageBitmap>"u"&&console.warn("THREE.ImageBitmapLoader: createImageBitmap() not supported."),typeof fetch>"u"&&console.warn("THREE.ImageBitmapLoader: fetch() not supported."),this.manager=e!==void 0?e:Mt,this.options=void 0}Us.prototype={constructor:Us,setOptions:function(t){return this.options=t,this},load:function(e,t,r,i){e===void 0&&(e=""),this.path!==void 0&&(e=this.path+e),e=this.manager.resolveURL(e);var n=this,a=kr.get(e);if(a!==void 0)return n.manager.itemStart(e),setTimeout(function(){t&&t(a),n.manager.itemEnd(e)},0),a;fetch(e).then(function(s){return s.blob()}).then(function(s){return createImageBitmap(s,n.options)}).then(function(s){kr.add(e,s),t&&t(s),n.manager.itemEnd(e)}).catch(function(s){i&&i(s),n.manager.itemError(e),n.manager.itemEnd(e)})},setCrossOrigin:function(){return this},setPath:function(e){return this.path=e,this}};function Do(){this.type="ShapePath",this.color=new oe,this.subPaths=[],this.currentPath=null}Object.assign(Do.prototype,{moveTo:function(e,t){this.currentPath=new It,this.subPaths.push(this.currentPath),this.currentPath.moveTo(e,t)},lineTo:function(e,t){this.currentPath.lineTo(e,t)},quadraticCurveTo:function(e,t,r,i){this.currentPath.quadraticCurveTo(e,t,r,i)},bezierCurveTo:function(e,t,r,i,n,a){this.currentPath.bezierCurveTo(e,t,r,i,n,a)},splineThru:function(e){this.currentPath.splineThru(e)},toShapes:function(e,t){function r(G){for(var J=[],Y=0,q=G.length;Y<q;Y++){var E=G[Y],T=new hr;T.curves=E.curves,J.push(T)}return J}function i(G,J){for(var Y=J.length,q=!1,E=Y-1,T=0;T<Y;E=T++){var U=J[E],L=J[T],Q=L.x-U.x,B=L.y-U.y;if(Math.abs(B)>Number.EPSILON){if(B<0&&(U=J[T],Q=-Q,L=J[E],B=-B),G.y<U.y||G.y>L.y)continue;if(G.y===U.y){if(G.x===U.x)return!0}else{var W=B*(G.x-U.x)-Q*(G.y-U.y);if(W===0)return!0;if(W<0)continue;q=!q}}else{if(G.y!==U.y)continue;if(L.x<=G.x&&G.x<=U.x||U.x<=G.x&&G.x<=L.x)return!0}}return q}var n=er.isClockWise,a=this.subPaths;if(a.length===0)return[];if(t===!0)return r(a);var s,o,h,c=[];if(a.length===1)return o=a[0],h=new hr,h.curves=o.curves,c.push(h),c;var u=!n(a[0].getPoints());u=e?!u:u;var l=[],f=[],d=[],p=0,m;f[p]=void 0,d[p]=[];for(var v=0,g=a.length;v<g;v++)o=a[v],m=o.getPoints(),s=n(m),s=e?!s:s,s?(!u&&f[p]&&p++,f[p]={s:new hr,p:m},f[p].s.curves=o.curves,u&&p++,d[p]=[]):d[p].push({h:o,p:m[0]});if(!f[0])return r(a);if(f.length>1){for(var _=!1,w=[],y=0,S=f.length;y<S;y++)l[y]=[];for(var y=0,S=f.length;y<S;y++)for(var R=d[y],I=0;I<R.length;I++){for(var C=R[I],A=!0,O=0;O<f.length;O++)i(C.p,f[O].p)&&(y!==O&&w.push({froms:y,tos:O,hole:I}),A?(A=!1,l[O].push(C)):_=!0);A&&l[y].push(C)}w.length>0&&(_||(d=l))}for(var F,v=0,N=f.length;v<N;v++){h=f[v].s,c.push(h),F=d[v];for(var V=0,k=F.length;V<k;V++)h.holes.push(F[V].h)}return c}});function Oo(e){this.type="Font",this.data=e}Object.assign(Oo.prototype,{isFont:!0,generateShapes:function(e,t){t===void 0&&(t=100);for(var r=[],i=ld(e,t,this.data),n=0,a=i.length;n<a;n++)Array.prototype.push.apply(r,i[n].toShapes());return r}});function ld(e,t,r){for(var i=Array.from?Array.from(e):String(e).split(""),n=t/r.resolution,a=(r.boundingBox.yMax-r.boundingBox.yMin+r.underlineThickness)*n,s=[],o=0,h=0,c=0;c<i.length;c++){var u=i[c];if(u===`
`)o=0,h-=a;else{var l=fd(u,n,o,h,r);o+=l.offsetX,s.push(l.path)}}return s}function fd(e,t,r,i,n){var a=n.glyphs[e]||n.glyphs["?"];if(a){var s=new Do,o,h,c,u,l,f,d,p;if(a.o)for(var m=a._cachedOutline||(a._cachedOutline=a.o.split(" ")),v=0,g=m.length;v<g;){var _=m[v++];switch(_){case"m":o=m[v++]*t+r,h=m[v++]*t+i,s.moveTo(o,h);break;case"l":o=m[v++]*t+r,h=m[v++]*t+i,s.lineTo(o,h);break;case"q":c=m[v++]*t+r,u=m[v++]*t+i,l=m[v++]*t+r,f=m[v++]*t+i,s.quadraticCurveTo(l,f,c,u);break;case"b":c=m[v++]*t+r,u=m[v++]*t+i,l=m[v++]*t+r,f=m[v++]*t+i,d=m[v++]*t+r,p=m[v++]*t+i,s.bezierCurveTo(l,f,d,p,c,u);break}}return{offsetX:a.ha*t,path:s}}}function dd(e){this.manager=e!==void 0?e:Mt}Object.assign(dd.prototype,{load:function(e,t,r,i){var n=this,a=new Jt(this.manager);a.setPath(this.path),a.load(e,function(s){var o;try{o=JSON.parse(s)}catch{console.warn("THREE.FontLoader: typeface.js support is being deprecated. Use typeface.json instead."),o=JSON.parse(s.substring(65,s.length-2))}var h=n.parse(o);t&&t(h)},r,i)},parse:function(e){return new Oo(e)},setPath:function(e){return this.path=e,this}});function In(){}In.Handlers={handlers:[],add:function(e,t){this.handlers.push(e,t)},get:function(e){for(var t=this.handlers,r=0,i=t.length;r<i;r+=2){var n=t[r],a=t[r+1];if(n.test(e))return a}return null}};Object.assign(In.prototype,{crossOrigin:"anonymous",onLoadStart:function(){},onLoadProgress:function(){},onLoadComplete:function(){},initMaterials:function(e,t,r){for(var i=[],n=0;n<e.length;++n)i[n]=this.createMaterial(e[n],t,r);return i},createMaterial:function(){var e={NoBlending:Jr,NormalBlending:br,AdditiveBlending:sa,SubtractiveBlending:oa,MultiplyBlending:ha,CustomBlending:Zs},t=new oe,r=new $a,i=new ts;return function(a,s,o){var h={};function c(d,p,m,v,g){var _=s+d,w=In.Handlers.get(_),y;w!==null?y=w.load(_):(r.setCrossOrigin(o),y=r.load(_)),p!==void 0&&(y.repeat.fromArray(p),p[0]!==1&&(y.wrapS=Qt),p[1]!==1&&(y.wrapT=Qt)),m!==void 0&&y.offset.fromArray(m),v!==void 0&&(v[0]==="repeat"&&(y.wrapS=Qt),v[0]==="mirror"&&(y.wrapS=Er),v[1]==="repeat"&&(y.wrapT=Qt),v[1]==="mirror"&&(y.wrapT=Er)),g!==void 0&&(y.anisotropy=g);var S=ge.generateUUID();return h[S]=y,S}var u={uuid:ge.generateUUID(),type:"MeshLambertMaterial"};for(var l in a){var f=a[l];switch(l){case"DbgColor":case"DbgIndex":case"opticalDensity":case"illumination":break;case"DbgName":u.name=f;break;case"blending":u.blending=e[f];break;case"colorAmbient":case"mapAmbient":console.warn("THREE.Loader.createMaterial:",l,"is no longer supported.");break;case"colorDiffuse":u.color=t.fromArray(f).getHex();break;case"colorSpecular":u.specular=t.fromArray(f).getHex();break;case"colorEmissive":u.emissive=t.fromArray(f).getHex();break;case"specularCoef":u.shininess=f;break;case"shading":f.toLowerCase()==="basic"&&(u.type="MeshBasicMaterial"),f.toLowerCase()==="phong"&&(u.type="MeshPhongMaterial"),f.toLowerCase()==="standard"&&(u.type="MeshStandardMaterial");break;case"mapDiffuse":u.map=c(f,a.mapDiffuseRepeat,a.mapDiffuseOffset,a.mapDiffuseWrap,a.mapDiffuseAnisotropy);break;case"mapDiffuseRepeat":case"mapDiffuseOffset":case"mapDiffuseWrap":case"mapDiffuseAnisotropy":break;case"mapEmissive":u.emissiveMap=c(f,a.mapEmissiveRepeat,a.mapEmissiveOffset,a.mapEmissiveWrap,a.mapEmissiveAnisotropy);break;case"mapEmissiveRepeat":case"mapEmissiveOffset":case"mapEmissiveWrap":case"mapEmissiveAnisotropy":break;case"mapLight":u.lightMap=c(f,a.mapLightRepeat,a.mapLightOffset,a.mapLightWrap,a.mapLightAnisotropy);break;case"mapLightRepeat":case"mapLightOffset":case"mapLightWrap":case"mapLightAnisotropy":break;case"mapAO":u.aoMap=c(f,a.mapAORepeat,a.mapAOOffset,a.mapAOWrap,a.mapAOAnisotropy);break;case"mapAORepeat":case"mapAOOffset":case"mapAOWrap":case"mapAOAnisotropy":break;case"mapBump":u.bumpMap=c(f,a.mapBumpRepeat,a.mapBumpOffset,a.mapBumpWrap,a.mapBumpAnisotropy);break;case"mapBumpScale":u.bumpScale=f;break;case"mapBumpRepeat":case"mapBumpOffset":case"mapBumpWrap":case"mapBumpAnisotropy":break;case"mapNormal":u.normalMap=c(f,a.mapNormalRepeat,a.mapNormalOffset,a.mapNormalWrap,a.mapNormalAnisotropy);break;case"mapNormalFactor":u.normalScale=f;break;case"mapNormalRepeat":case"mapNormalOffset":case"mapNormalWrap":case"mapNormalAnisotropy":break;case"mapSpecular":u.specularMap=c(f,a.mapSpecularRepeat,a.mapSpecularOffset,a.mapSpecularWrap,a.mapSpecularAnisotropy);break;case"mapSpecularRepeat":case"mapSpecularOffset":case"mapSpecularWrap":case"mapSpecularAnisotropy":break;case"mapMetalness":u.metalnessMap=c(f,a.mapMetalnessRepeat,a.mapMetalnessOffset,a.mapMetalnessWrap,a.mapMetalnessAnisotropy);break;case"mapMetalnessRepeat":case"mapMetalnessOffset":case"mapMetalnessWrap":case"mapMetalnessAnisotropy":break;case"mapRoughness":u.roughnessMap=c(f,a.mapRoughnessRepeat,a.mapRoughnessOffset,a.mapRoughnessWrap,a.mapRoughnessAnisotropy);break;case"mapRoughnessRepeat":case"mapRoughnessOffset":case"mapRoughnessWrap":case"mapRoughnessAnisotropy":break;case"mapAlpha":u.alphaMap=c(f,a.mapAlphaRepeat,a.mapAlphaOffset,a.mapAlphaWrap,a.mapAlphaAnisotropy);break;case"mapAlphaRepeat":case"mapAlphaOffset":case"mapAlphaWrap":case"mapAlphaAnisotropy":break;case"flipSided":u.side=st;break;case"doubleSided":u.side=Ni;break;case"transparency":console.warn("THREE.Loader.createMaterial: transparency has been renamed to opacity"),u.opacity=f;break;case"depthTest":case"depthWrite":case"colorWrite":case"opacity":case"reflectivity":case"transparent":case"visible":case"wireframe":u[l]=f;break;case"vertexColors":f===!0&&(u.vertexColors=Wr),f==="face"&&(u.vertexColors=Ys);break;default:console.error("THREE.Loader.createMaterial: Unsupported",l,f);break}}return u.type==="MeshBasicMaterial"&&delete u.emissive,u.type!=="MeshPhongMaterial"&&delete u.specular,u.opacity<1&&(u.transparent=!0),i.setTextures(h),i.parse(u)}}()});var ji,Fo={getContext:function(){return ji===void 0&&(ji=new(window.AudioContext||window.webkitAudioContext)),ji},setContext:function(e){ji=e}};function Uo(e){this.manager=e!==void 0?e:Mt}Object.assign(Uo.prototype,{load:function(e,t,r,i){var n=new Jt(this.manager);n.setResponseType("arraybuffer"),n.setPath(this.path),n.load(e,function(a){var s=a.slice(0),o=Fo.getContext();o.decodeAudioData(s,function(h){t(h)})},r,i)},setPath:function(e){return this.path=e,this}});function pd(){this.type="StereoCamera",this.aspect=1,this.eyeSep=.064,this.cameraL=new je,this.cameraL.layers.enable(1),this.cameraL.matrixAutoUpdate=!1,this.cameraR=new je,this.cameraR.layers.enable(2),this.cameraR.matrixAutoUpdate=!1}Object.assign(pd.prototype,{update:function(){var e,t,r,i,n,a,s,o,h=new fe,c=new fe;return function(l){var f=e!==this||t!==l.focus||r!==l.fov||i!==l.aspect*this.aspect||n!==l.near||a!==l.far||s!==l.zoom||o!==this.eyeSep;if(f){e=this,t=l.focus,r=l.fov,i=l.aspect*this.aspect,n=l.near,a=l.far,s=l.zoom;var d=l.projectionMatrix.clone();o=this.eyeSep/2;var p=o*n/t,m=n*Math.tan(ge.DEG2RAD*r*.5)/s,v,g;c.elements[12]=-o,h.elements[12]=o,v=-m*i+p,g=m*i+p,d.elements[0]=2*n/(g-v),d.elements[8]=(g+v)/(g-v),this.cameraL.projectionMatrix.copy(d),v=-m*i-p,g=m*i-p,d.elements[0]=2*n/(g-v),d.elements[8]=(g+v)/(g-v),this.cameraR.projectionMatrix.copy(d)}this.cameraL.matrixWorld.copy(l.matrixWorld).multiply(c),this.cameraR.matrixWorld.copy(l.matrixWorld).multiply(h)}}()});function Dn(e,t,r,i){K.call(this),this.type="CubeCamera";var n=90,a=1,s=new je(n,a,e,t);s.up.set(0,-1,0),s.lookAt(new b(1,0,0)),this.add(s);var o=new je(n,a,e,t);o.up.set(0,-1,0),o.lookAt(new b(-1,0,0)),this.add(o);var h=new je(n,a,e,t);h.up.set(0,0,1),h.lookAt(new b(0,1,0)),this.add(h);var c=new je(n,a,e,t);c.up.set(0,0,-1),c.lookAt(new b(0,-1,0)),this.add(c);var u=new je(n,a,e,t);u.up.set(0,-1,0),u.lookAt(new b(0,0,1)),this.add(u);var l=new je(n,a,e,t);l.up.set(0,-1,0),l.lookAt(new b(0,0,-1)),this.add(l),i=i||{format:cr,magFilter:it,minFilter:it},this.renderTarget=new ti(r,r,i),this.renderTarget.texture.name="CubeCamera",this.update=function(f,d){this.parent===null&&this.updateMatrixWorld();var p=f.getRenderTarget(),m=this.renderTarget,v=m.texture.generateMipmaps;m.texture.generateMipmaps=!1,m.activeCubeFace=0,f.render(d,s,m),m.activeCubeFace=1,f.render(d,o,m),m.activeCubeFace=2,f.render(d,h,m),m.activeCubeFace=3,f.render(d,c,m),m.activeCubeFace=4,f.render(d,u,m),m.texture.generateMipmaps=v,m.activeCubeFace=5,f.render(d,l,m),f.setRenderTarget(p)},this.clear=function(f,d,p,m){for(var v=f.getRenderTarget(),g=this.renderTarget,_=0;_<6;_++)g.activeCubeFace=_,f.setRenderTarget(g),f.clear(d,p,m);f.setRenderTarget(v)}}Dn.prototype=Object.create(K.prototype);Dn.prototype.constructor=Dn;function Bo(e){this.autoStart=e!==void 0?e:!0,this.startTime=0,this.oldTime=0,this.elapsedTime=0,this.running=!1}Object.assign(Bo.prototype,{start:function(){this.startTime=(typeof performance>"u"?Date:performance).now(),this.oldTime=this.startTime,this.elapsedTime=0,this.running=!0},stop:function(){this.getElapsedTime(),this.running=!1,this.autoStart=!1},getElapsedTime:function(){return this.getDelta(),this.elapsedTime},getDelta:function(){var e=0;if(this.autoStart&&!this.running)return this.start(),0;if(this.running){var t=(typeof performance>"u"?Date:performance).now();e=(t-this.oldTime)/1e3,this.oldTime=t,this.elapsedTime+=e}return e}});function Bs(){K.call(this),this.type="AudioListener",this.context=Fo.getContext(),this.gain=this.context.createGain(),this.gain.connect(this.context.destination),this.filter=null,this.timeDelta=0}Bs.prototype=Object.assign(Object.create(K.prototype),{constructor:Bs,getInput:function(){return this.gain},removeFilter:function(){return this.filter!==null&&(this.gain.disconnect(this.filter),this.filter.disconnect(this.context.destination),this.gain.connect(this.context.destination),this.filter=null),this},getFilter:function(){return this.filter},setFilter:function(e){return this.filter!==null?(this.gain.disconnect(this.filter),this.filter.disconnect(this.context.destination)):this.gain.disconnect(this.context.destination),this.filter=e,this.gain.connect(this.filter),this.filter.connect(this.context.destination),this},getMasterVolume:function(){return this.gain.gain.value},setMasterVolume:function(e){return this.gain.gain.setTargetAtTime(e,this.context.currentTime,.01),this},updateMatrixWorld:function(){var e=new b,t=new Qe,r=new b,i=new b,n=new Bo;return function(s){K.prototype.updateMatrixWorld.call(this,s);var o=this.context.listener,h=this.up;if(this.timeDelta=n.getDelta(),this.matrixWorld.decompose(e,t,r),i.set(0,0,-1).applyQuaternion(t),o.positionX){var c=this.context.currentTime+this.timeDelta;o.positionX.linearRampToValueAtTime(e.x,c),o.positionY.linearRampToValueAtTime(e.y,c),o.positionZ.linearRampToValueAtTime(e.z,c),o.forwardX.linearRampToValueAtTime(i.x,c),o.forwardY.linearRampToValueAtTime(i.y,c),o.forwardZ.linearRampToValueAtTime(i.z,c),o.upX.linearRampToValueAtTime(h.x,c),o.upY.linearRampToValueAtTime(h.y,c),o.upZ.linearRampToValueAtTime(h.z,c)}else o.setPosition(e.x,e.y,e.z),o.setOrientation(i.x,i.y,i.z,h.x,h.y,h.z)}}()});function Pi(e){K.call(this),this.type="Audio",this.listener=e,this.context=e.context,this.gain=this.context.createGain(),this.gain.connect(e.getInput()),this.autoplay=!1,this.buffer=null,this.detune=0,this.loop=!1,this.startTime=0,this.offset=0,this.playbackRate=1,this.isPlaying=!1,this.hasPlaybackControl=!0,this.sourceType="empty",this.filters=[]}Pi.prototype=Object.assign(Object.create(K.prototype),{constructor:Pi,getOutput:function(){return this.gain},setNodeSource:function(e){return this.hasPlaybackControl=!1,this.sourceType="audioNode",this.source=e,this.connect(),this},setMediaElementSource:function(e){return this.hasPlaybackControl=!1,this.sourceType="mediaNode",this.source=this.context.createMediaElementSource(e),this.connect(),this},setBuffer:function(e){return this.buffer=e,this.sourceType="buffer",this.autoplay&&this.play(),this},play:function(){if(this.isPlaying===!0){console.warn("THREE.Audio: Audio is already playing.");return}if(this.hasPlaybackControl===!1){console.warn("THREE.Audio: this Audio has no playback control.");return}var e=this.context.createBufferSource();return e.buffer=this.buffer,e.detune.value=this.detune,e.loop=this.loop,e.onended=this.onEnded.bind(this),e.playbackRate.setValueAtTime(this.playbackRate,this.startTime),this.startTime=this.context.currentTime,e.start(this.startTime,this.offset),this.isPlaying=!0,this.source=e,this.connect()},pause:function(){if(this.hasPlaybackControl===!1){console.warn("THREE.Audio: this Audio has no playback control.");return}return this.isPlaying===!0&&(this.source.stop(),this.source.onended=null,this.offset+=(this.context.currentTime-this.startTime)*this.playbackRate,this.isPlaying=!1),this},stop:function(){if(this.hasPlaybackControl===!1){console.warn("THREE.Audio: this Audio has no playback control.");return}return this.source.stop(),this.source.onended=null,this.offset=0,this.isPlaying=!1,this},connect:function(){if(this.filters.length>0){this.source.connect(this.filters[0]);for(var e=1,t=this.filters.length;e<t;e++)this.filters[e-1].connect(this.filters[e]);this.filters[this.filters.length-1].connect(this.getOutput())}else this.source.connect(this.getOutput());return this},disconnect:function(){if(this.filters.length>0){this.source.disconnect(this.filters[0]);for(var e=1,t=this.filters.length;e<t;e++)this.filters[e-1].disconnect(this.filters[e]);this.filters[this.filters.length-1].disconnect(this.getOutput())}else this.source.disconnect(this.getOutput());return this},getFilters:function(){return this.filters},setFilters:function(e){return e||(e=[]),this.isPlaying===!0?(this.disconnect(),this.filters=e,this.connect()):this.filters=e,this},setDetune:function(e){return this.detune=e,this.isPlaying===!0&&this.source.detune.setTargetAtTime(this.detune,this.context.currentTime,.01),this},getDetune:function(){return this.detune},getFilter:function(){return this.getFilters()[0]},setFilter:function(e){return this.setFilters(e?[e]:[])},setPlaybackRate:function(e){if(this.hasPlaybackControl===!1){console.warn("THREE.Audio: this Audio has no playback control.");return}return this.playbackRate=e,this.isPlaying===!0&&this.source.playbackRate.setTargetAtTime(this.playbackRate,this.context.currentTime,.01),this},getPlaybackRate:function(){return this.playbackRate},onEnded:function(){this.isPlaying=!1},getLoop:function(){return this.hasPlaybackControl===!1?(console.warn("THREE.Audio: this Audio has no playback control."),!1):this.loop},setLoop:function(e){if(this.hasPlaybackControl===!1){console.warn("THREE.Audio: this Audio has no playback control.");return}return this.loop=e,this.isPlaying===!0&&(this.source.loop=this.loop),this},getVolume:function(){return this.gain.gain.value},setVolume:function(e){return this.gain.gain.setTargetAtTime(e,this.context.currentTime,.01),this}});function Ns(e){Pi.call(this,e),this.panner=this.context.createPanner(),this.panner.connect(this.gain)}Ns.prototype=Object.assign(Object.create(Pi.prototype),{constructor:Ns,getOutput:function(){return this.panner},getRefDistance:function(){return this.panner.refDistance},setRefDistance:function(e){return this.panner.refDistance=e,this},getRolloffFactor:function(){return this.panner.rolloffFactor},setRolloffFactor:function(e){return this.panner.rolloffFactor=e,this},getDistanceModel:function(){return this.panner.distanceModel},setDistanceModel:function(e){return this.panner.distanceModel=e,this},getMaxDistance:function(){return this.panner.maxDistance},setMaxDistance:function(e){return this.panner.maxDistance=e,this},setDirectionalCone:function(e,t,r){return this.panner.coneInnerAngle=e,this.panner.coneOuterAngle=t,this.panner.coneOuterGain=r,this},updateMatrixWorld:function(){var e=new b,t=new Qe,r=new b,i=new b;return function(a){if(K.prototype.updateMatrixWorld.call(this,a),this.isPlaying!==!1){this.matrixWorld.decompose(e,t,r),i.set(0,0,1).applyQuaternion(t);var s=this.panner;if(s.positionX){var o=this.context.currentTime+this.listener.timeDelta;s.positionX.linearRampToValueAtTime(e.x,o),s.positionY.linearRampToValueAtTime(e.y,o),s.positionZ.linearRampToValueAtTime(e.z,o),s.orientationX.linearRampToValueAtTime(i.x,o),s.orientationY.linearRampToValueAtTime(i.y,o),s.orientationZ.linearRampToValueAtTime(i.z,o)}else s.setPosition(e.x,e.y,e.z),s.setOrientation(i.x,i.y,i.z)}}}()});function No(e,t){this.analyser=e.context.createAnalyser(),this.analyser.fftSize=t!==void 0?t:2048,this.data=new Uint8Array(this.analyser.frequencyBinCount),e.getOutput().connect(this.analyser)}Object.assign(No.prototype,{getFrequencyData:function(){return this.analyser.getByteFrequencyData(this.data),this.data},getAverageFrequency:function(){for(var e=0,t=this.getFrequencyData(),r=0;r<t.length;r++)e+=t[r];return e/t.length}});function Go(e,t,r){this.binding=e,this.valueSize=r;var i=Float64Array,n;switch(t){case"quaternion":n=this._slerp;break;case"string":case"bool":i=Array,n=this._select;break;default:n=this._lerp}this.buffer=new i(r*4),this._mixBufferRegion=n,this.cumulativeWeight=0,this.useCount=0,this.referenceCount=0}Object.assign(Go.prototype,{accumulate:function(e,t){var r=this.buffer,i=this.valueSize,n=e*i+i,a=this.cumulativeWeight;if(a===0){for(var s=0;s!==i;++s)r[n+s]=r[s];a=t}else{a+=t;var o=t/a;this._mixBufferRegion(r,n,0,o,i)}this.cumulativeWeight=a},apply:function(e){var t=this.valueSize,r=this.buffer,i=e*t+t,n=this.cumulativeWeight,a=this.binding;if(this.cumulativeWeight=0,n<1){var s=t*3;this._mixBufferRegion(r,i,s,1-n,t)}for(var o=t,h=t+t;o!==h;++o)if(r[o]!==r[o+t]){a.setValue(r,i);break}},saveOriginalState:function(){var e=this.binding,t=this.buffer,r=this.valueSize,i=r*3;e.getValue(t,i);for(var n=r,a=i;n!==a;++n)t[n]=t[i+n%r];this.cumulativeWeight=0},restoreOriginalState:function(){var e=this.valueSize*3;this.binding.setValue(this.buffer,e)},_select:function(e,t,r,i,n){if(i>=.5)for(var a=0;a!==n;++a)e[t+a]=e[r+a]},_slerp:function(e,t,r,i){Qe.slerpFlat(e,t,e,t,e,r,i)},_lerp:function(e,t,r,i,n){for(var a=1-i,s=0;s!==n;++s){var o=t+s;e[o]=e[o]*a+e[r+s]*i}}});var na="\\[\\]\\.:\\/";function zo(e,t,r){var i=r||ut.parseTrackName(t);this._targetGroup=e,this._bindings=e.subscribe_(t,i)}Object.assign(zo.prototype,{getValue:function(e,t){this.bind();var r=this._targetGroup.nCachedObjects_,i=this._bindings[r];i!==void 0&&i.getValue(e,t)},setValue:function(e,t){for(var r=this._bindings,i=this._targetGroup.nCachedObjects_,n=r.length;i!==n;++i)r[i].setValue(e,t)},bind:function(){for(var e=this._bindings,t=this._targetGroup.nCachedObjects_,r=e.length;t!==r;++t)e[t].bind()},unbind:function(){for(var e=this._bindings,t=this._targetGroup.nCachedObjects_,r=e.length;t!==r;++t)e[t].unbind()}});function ut(e,t,r){this.path=t,this.parsedPath=r||ut.parseTrackName(t),this.node=ut.findNode(e,this.parsedPath.nodeName)||e,this.rootNode=e}Object.assign(ut,{Composite:zo,create:function(e,t,r){return e&&e.isAnimationObjectGroup?new ut.Composite(e,t,r):new ut(e,t,r)},sanitizeNodeName:function(){var e=new RegExp("["+na+"]","g");return function(r){return r.replace(/\s/g,"_").replace(e,"")}}(),parseTrackName:function(){var e="[^"+na+"]",t="[^"+na.replace("\\.","")+"]",r=/((?:WC+[\/:])*)/.source.replace("WC",e),i=/(WCOD+)?/.source.replace("WCOD",t),n=/(?:\.(WC+)(?:\[(.+)\])?)?/.source.replace("WC",e),a=/\.(WC+)(?:\[(.+)\])?/.source.replace("WC",e),s=new RegExp("^"+r+i+n+a+"$"),o=["material","materials","bones"];return function(c){var u=s.exec(c);if(!u)throw new Error("PropertyBinding: Cannot parse trackName: "+c);var l={nodeName:u[2],objectName:u[3],objectIndex:u[4],propertyName:u[5],propertyIndex:u[6]},f=l.nodeName&&l.nodeName.lastIndexOf(".");if(f!==void 0&&f!==-1){var d=l.nodeName.substring(f+1);o.indexOf(d)!==-1&&(l.nodeName=l.nodeName.substring(0,f),l.objectName=d)}if(l.propertyName===null||l.propertyName.length===0)throw new Error("PropertyBinding: can not parse propertyName from trackName: "+c);return l}}(),findNode:function(e,t){if(!t||t===""||t==="root"||t==="."||t===-1||t===e.name||t===e.uuid)return e;if(e.skeleton){var r=e.skeleton.getBoneByName(t);if(r!==void 0)return r}if(e.children){var i=function(a){for(var s=0;s<a.length;s++){var o=a[s];if(o.name===t||o.uuid===t)return o;var h=i(o.children);if(h)return h}return null},n=i(e.children);if(n)return n}return null}});Object.assign(ut.prototype,{_getValue_unavailable:function(){},_setValue_unavailable:function(){},BindingType:{Direct:0,EntireArray:1,ArrayElement:2,HasFromToArray:3},Versioning:{None:0,NeedsUpdate:1,MatrixWorldNeedsUpdate:2},GetterByBindingType:[function(t,r){t[r]=this.node[this.propertyName]},function(t,r){for(var i=this.resolvedProperty,n=0,a=i.length;n!==a;++n)t[r++]=i[n]},function(t,r){t[r]=this.resolvedProperty[this.propertyIndex]},function(t,r){this.resolvedProperty.toArray(t,r)}],SetterByBindingTypeAndVersioning:[[function(t,r){this.targetObject[this.propertyName]=t[r]},function(t,r){this.targetObject[this.propertyName]=t[r],this.targetObject.needsUpdate=!0},function(t,r){this.targetObject[this.propertyName]=t[r],this.targetObject.matrixWorldNeedsUpdate=!0}],[function(t,r){for(var i=this.resolvedProperty,n=0,a=i.length;n!==a;++n)i[n]=t[r++]},function(t,r){for(var i=this.resolvedProperty,n=0,a=i.length;n!==a;++n)i[n]=t[r++];this.targetObject.needsUpdate=!0},function(t,r){for(var i=this.resolvedProperty,n=0,a=i.length;n!==a;++n)i[n]=t[r++];this.targetObject.matrixWorldNeedsUpdate=!0}],[function(t,r){this.resolvedProperty[this.propertyIndex]=t[r]},function(t,r){this.resolvedProperty[this.propertyIndex]=t[r],this.targetObject.needsUpdate=!0},function(t,r){this.resolvedProperty[this.propertyIndex]=t[r],this.targetObject.matrixWorldNeedsUpdate=!0}],[function(t,r){this.resolvedProperty.fromArray(t,r)},function(t,r){this.resolvedProperty.fromArray(t,r),this.targetObject.needsUpdate=!0},function(t,r){this.resolvedProperty.fromArray(t,r),this.targetObject.matrixWorldNeedsUpdate=!0}]],getValue:function(t,r){this.bind(),this.getValue(t,r)},setValue:function(t,r){this.bind(),this.setValue(t,r)},bind:function(){var e=this.node,t=this.parsedPath,r=t.objectName,i=t.propertyName,n=t.propertyIndex;if(e||(e=ut.findNode(this.rootNode,t.nodeName)||this.rootNode,this.node=e),this.getValue=this._getValue_unavailable,this.setValue=this._setValue_unavailable,!e){console.error("THREE.PropertyBinding: Trying to update node for track: "+this.path+" but it wasn't found.");return}if(r){var a=t.objectIndex;switch(r){case"materials":if(!e.material){console.error("THREE.PropertyBinding: Can not bind to material as node does not have a material.",this);return}if(!e.material.materials){console.error("THREE.PropertyBinding: Can not bind to material.materials as node.material does not have a materials array.",this);return}e=e.material.materials;break;case"bones":if(!e.skeleton){console.error("THREE.PropertyBinding: Can not bind to bones as node does not have a skeleton.",this);return}e=e.skeleton.bones;for(var s=0;s<e.length;s++)if(e[s].name===a){a=s;break}break;default:if(e[r]===void 0){console.error("THREE.PropertyBinding: Can not bind to objectName of node undefined.",this);return}e=e[r]}if(a!==void 0){if(e[a]===void 0){console.error("THREE.PropertyBinding: Trying to bind to objectIndex of objectName, but is undefined.",this,e);return}e=e[a]}}var o=e[i];if(o===void 0){var h=t.nodeName;console.error("THREE.PropertyBinding: Trying to update property for track: "+h+"."+i+" but it wasn't found.",e);return}var c=this.Versioning.None;this.targetObject=e,e.needsUpdate!==void 0?c=this.Versioning.NeedsUpdate:e.matrixWorldNeedsUpdate!==void 0&&(c=this.Versioning.MatrixWorldNeedsUpdate);var u=this.BindingType.Direct;if(n!==void 0){if(i==="morphTargetInfluences"){if(!e.geometry){console.error("THREE.PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.",this);return}if(e.geometry.isBufferGeometry){if(!e.geometry.morphAttributes){console.error("THREE.PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.morphAttributes.",this);return}for(var s=0;s<this.node.geometry.morphAttributes.position.length;s++)if(e.geometry.morphAttributes.position[s].name===n){n=s;break}}else{if(!e.geometry.morphTargets){console.error("THREE.PropertyBinding: Can not bind to morphTargetInfluences because node does not have a geometry.morphTargets.",this);return}for(var s=0;s<this.node.geometry.morphTargets.length;s++)if(e.geometry.morphTargets[s].name===n){n=s;break}}}u=this.BindingType.ArrayElement,this.resolvedProperty=o,this.propertyIndex=n}else o.fromArray!==void 0&&o.toArray!==void 0?(u=this.BindingType.HasFromToArray,this.resolvedProperty=o):Array.isArray(o)?(u=this.BindingType.EntireArray,this.resolvedProperty=o):this.propertyName=i;this.getValue=this.GetterByBindingType[u],this.setValue=this.SetterByBindingTypeAndVersioning[u][c]},unbind:function(){this.node=null,this.getValue=this._getValue_unbound,this.setValue=this._setValue_unbound}});//!\ DECLARE ALIAS AFTER assign prototype !
Object.assign(ut.prototype,{_getValue_unbound:ut.prototype.getValue,_setValue_unbound:ut.prototype.setValue});function md(){this.uuid=ge.generateUUID(),this._objects=Array.prototype.slice.call(arguments),this.nCachedObjects_=0;var e={};this._indicesByUUID=e;for(var t=0,r=arguments.length;t!==r;++t)e[arguments[t].uuid]=t;this._paths=[],this._parsedPaths=[],this._bindings=[],this._bindingsIndicesByPath={};var i=this;this.stats={objects:{get total(){return i._objects.length},get inUse(){return this.total-i.nCachedObjects_}},get bindingsPerObject(){return i._bindings.length}}}Object.assign(md.prototype,{isAnimationObjectGroup:!0,add:function(){for(var e=this._objects,t=e.length,r=this.nCachedObjects_,i=this._indicesByUUID,n=this._paths,a=this._parsedPaths,s=this._bindings,o=s.length,h=void 0,c=0,u=arguments.length;c!==u;++c){var l=arguments[c],f=l.uuid,d=i[f];if(d===void 0){d=t++,i[f]=d,e.push(l);for(var p=0,m=o;p!==m;++p)s[p].push(new ut(l,n[p],a[p]))}else if(d<r){h=e[d];var v=--r,g=e[v];i[g.uuid]=d,e[d]=g,i[f]=v,e[v]=l;for(var p=0,m=o;p!==m;++p){var _=s[p],w=_[v],y=_[d];_[d]=w,y===void 0&&(y=new ut(l,n[p],a[p])),_[v]=y}}else e[d]!==h&&console.error("THREE.AnimationObjectGroup: Different objects with the same UUID detected. Clean the caches or recreate your infrastructure when reloading scenes.")}this.nCachedObjects_=r},remove:function(){for(var e=this._objects,t=this.nCachedObjects_,r=this._indicesByUUID,i=this._bindings,n=i.length,a=0,s=arguments.length;a!==s;++a){var o=arguments[a],h=o.uuid,c=r[h];if(c!==void 0&&c>=t){var u=t++,l=e[u];r[l.uuid]=c,e[c]=l,r[h]=u,e[u]=o;for(var f=0,d=n;f!==d;++f){var p=i[f],m=p[u],v=p[c];p[c]=m,p[u]=v}}}this.nCachedObjects_=t},uncache:function(){for(var e=this._objects,t=e.length,r=this.nCachedObjects_,i=this._indicesByUUID,n=this._bindings,a=n.length,s=0,o=arguments.length;s!==o;++s){var h=arguments[s],c=h.uuid,u=i[c];if(u!==void 0)if(delete i[c],u<r){var l=--r,f=e[l],d=--t,p=e[d];i[f.uuid]=u,e[u]=f,i[p.uuid]=l,e[l]=p,e.pop();for(var m=0,v=a;m!==v;++m){var g=n[m],_=g[l],w=g[d];g[u]=_,g[l]=w,g.pop()}}else{var d=--t,p=e[d];i[p.uuid]=u,e[u]=p,e.pop();for(var m=0,v=a;m!==v;++m){var g=n[m];g[u]=g[d],g.pop()}}}this.nCachedObjects_=r},subscribe_:function(e,t){var r=this._bindingsIndicesByPath,i=r[e],n=this._bindings;if(i!==void 0)return n[i];var a=this._paths,s=this._parsedPaths,o=this._objects,h=o.length,c=this.nCachedObjects_,u=new Array(h);i=n.length,r[e]=i,a.push(e),s.push(t),n.push(u);for(var l=c,f=o.length;l!==f;++l){var d=o[l];u[l]=new ut(d,e,t)}return u},unsubscribe_:function(e){var t=this._bindingsIndicesByPath,r=t[e];if(r!==void 0){var i=this._paths,n=this._parsedPaths,a=this._bindings,s=a.length-1,o=a[s],h=e[s];t[h]=r,a[r]=o,a.pop(),n[r]=n[s],n.pop(),i[r]=i[s],i.pop()}}});function Ho(e,t,r){this._mixer=e,this._clip=t,this._localRoot=r||null;for(var i=t.tracks,n=i.length,a=new Array(n),s={endingStart:Tr,endingEnd:Tr},o=0;o!==n;++o){var h=i[o].createInterpolant(null);a[o]=h,h.settings=s}this._interpolantSettings=s,this._interpolants=a,this._propertyBindings=new Array(n),this._cacheIndex=null,this._byClipCacheIndex=null,this._timeScaleInterpolant=null,this._weightInterpolant=null,this.loop=$h,this._loopCount=-1,this._startTime=null,this.time=0,this.timeScale=1,this._effectiveTimeScale=1,this.weight=1,this._effectiveWeight=1,this.repetitions=1/0,this.paused=!1,this.enabled=!0,this.clampWhenFinished=!1,this.zeroSlopeAtStart=!0,this.zeroSlopeAtEnd=!0}Object.assign(Ho.prototype,{play:function(){return this._mixer._activateAction(this),this},stop:function(){return this._mixer._deactivateAction(this),this.reset()},reset:function(){return this.paused=!1,this.enabled=!0,this.time=0,this._loopCount=-1,this._startTime=null,this.stopFading().stopWarping()},isRunning:function(){return this.enabled&&!this.paused&&this.timeScale!==0&&this._startTime===null&&this._mixer._isActiveAction(this)},isScheduled:function(){return this._mixer._isActiveAction(this)},startAt:function(e){return this._startTime=e,this},setLoop:function(e,t){return this.loop=e,this.repetitions=t,this},setEffectiveWeight:function(e){return this.weight=e,this._effectiveWeight=this.enabled?e:0,this.stopFading()},getEffectiveWeight:function(){return this._effectiveWeight},fadeIn:function(e){return this._scheduleFading(e,0,1)},fadeOut:function(e){return this._scheduleFading(e,1,0)},crossFadeFrom:function(e,t,r){if(e.fadeOut(t),this.fadeIn(t),r){var i=this._clip.duration,n=e._clip.duration,a=n/i,s=i/n;e.warp(1,a,t),this.warp(s,1,t)}return this},crossFadeTo:function(e,t,r){return e.crossFadeFrom(this,t,r)},stopFading:function(){var e=this._weightInterpolant;return e!==null&&(this._weightInterpolant=null,this._mixer._takeBackControlInterpolant(e)),this},setEffectiveTimeScale:function(e){return this.timeScale=e,this._effectiveTimeScale=this.paused?0:e,this.stopWarping()},getEffectiveTimeScale:function(){return this._effectiveTimeScale},setDuration:function(e){return this.timeScale=this._clip.duration/e,this.stopWarping()},syncWith:function(e){return this.time=e.time,this.timeScale=e.timeScale,this.stopWarping()},halt:function(e){return this.warp(this._effectiveTimeScale,0,e)},warp:function(e,t,r){var i=this._mixer,n=i.time,a=this._timeScaleInterpolant,s=this.timeScale;a===null&&(a=i._lendControlInterpolant(),this._timeScaleInterpolant=a);var o=a.parameterPositions,h=a.sampleValues;return o[0]=n,o[1]=n+r,h[0]=e/s,h[1]=t/s,this},stopWarping:function(){var e=this._timeScaleInterpolant;return e!==null&&(this._timeScaleInterpolant=null,this._mixer._takeBackControlInterpolant(e)),this},getMixer:function(){return this._mixer},getClip:function(){return this._clip},getRoot:function(){return this._localRoot||this._mixer._root},_update:function(e,t,r,i){if(!this.enabled){this._updateWeight(e);return}var n=this._startTime;if(n!==null){var a=(e-n)*r;if(a<0||r===0)return;this._startTime=null,t=r*a}t*=this._updateTimeScale(e);var s=this._updateTime(t),o=this._updateWeight(e);if(o>0)for(var h=this._interpolants,c=this._propertyBindings,u=0,l=h.length;u!==l;++u)h[u].evaluate(s),c[u].accumulate(i,o)},_updateWeight:function(e){var t=0;if(this.enabled){t=this.weight;var r=this._weightInterpolant;if(r!==null){var i=r.evaluate(e)[0];t*=i,e>r.parameterPositions[1]&&(this.stopFading(),i===0&&(this.enabled=!1))}}return this._effectiveWeight=t,t},_updateTimeScale:function(e){var t=0;if(!this.paused){t=this.timeScale;var r=this._timeScaleInterpolant;if(r!==null){var i=r.evaluate(e)[0];t*=i,e>r.parameterPositions[1]&&(this.stopWarping(),t===0?this.paused=!0:this.timeScale=t)}}return this._effectiveTimeScale=t,t},_updateTime:function(e){var t=this.time+e,r=this._clip.duration,i=this.loop,n=this._loopCount,a=i===ec;if(e===0)return n===-1?t:a&&(n&1)===1?r-t:t;if(i===Kh){n===-1&&(this._loopCount=0,this._setEndings(!0,!0,!1));e:{if(t>=r)t=r;else if(t<0)t=0;else break e;this.clampWhenFinished?this.paused=!0:this.enabled=!1,this._mixer.dispatchEvent({type:"finished",action:this,direction:e<0?-1:1})}}else{if(n===-1&&(e>=0?(n=0,this._setEndings(!0,this.repetitions===0,a)):this._setEndings(this.repetitions===0,!0,a)),t>=r||t<0){var s=Math.floor(t/r);t-=r*s,n+=Math.abs(s);var o=this.repetitions-n;if(o<=0)this.clampWhenFinished?this.paused=!0:this.enabled=!1,t=e>0?r:0,this._mixer.dispatchEvent({type:"finished",action:this,direction:e>0?1:-1});else{if(o===1){var h=e<0;this._setEndings(h,!h,a)}else this._setEndings(!1,!1,a);this._loopCount=n,this._mixer.dispatchEvent({type:"loop",action:this,loopDelta:s})}}if(a&&(n&1)===1)return this.time=t,r-t}return this.time=t,t},_setEndings:function(e,t,r){var i=this._interpolantSettings;r?(i.endingStart=wr,i.endingEnd=wr):(e?i.endingStart=this.zeroSlopeAtStart?wr:Tr:i.endingStart=Ki,t?i.endingEnd=this.zeroSlopeAtEnd?wr:Tr:i.endingEnd=Ki)},_scheduleFading:function(e,t,r){var i=this._mixer,n=i.time,a=this._weightInterpolant;a===null&&(a=i._lendControlInterpolant(),this._weightInterpolant=a);var s=a.parameterPositions,o=a.sampleValues;return s[0]=n,o[0]=t,s[1]=n+e,o[1]=r,this}});function Gs(e){this._root=e,this._initMemoryManager(),this._accuIndex=0,this.time=0,this.timeScale=1}Gs.prototype=Object.assign(Object.create(ar.prototype),{constructor:Gs,_bindAction:function(e,t){var r=e._localRoot||this._root,i=e._clip.tracks,n=i.length,a=e._propertyBindings,s=e._interpolants,o=r.uuid,h=this._bindingsByRootAndName,c=h[o];c===void 0&&(c={},h[o]=c);for(var u=0;u!==n;++u){var l=i[u],f=l.name,d=c[f];if(d!==void 0)a[u]=d;else{if(d=a[u],d!==void 0){d._cacheIndex===null&&(++d.referenceCount,this._addInactiveBinding(d,o,f));continue}var p=t&&t._propertyBindings[u].binding.parsedPath;d=new Go(ut.create(r,f,p),l.ValueTypeName,l.getValueSize()),++d.referenceCount,this._addInactiveBinding(d,o,f),a[u]=d}s[u].resultBuffer=d.buffer}},_activateAction:function(e){if(!this._isActiveAction(e)){if(e._cacheIndex===null){var t=(e._localRoot||this._root).uuid,r=e._clip.uuid,i=this._actionsByClip[r];this._bindAction(e,i&&i.knownActions[0]),this._addInactiveAction(e,r,t)}for(var n=e._propertyBindings,a=0,s=n.length;a!==s;++a){var o=n[a];o.useCount++===0&&(this._lendBinding(o),o.saveOriginalState())}this._lendAction(e)}},_deactivateAction:function(e){if(this._isActiveAction(e)){for(var t=e._propertyBindings,r=0,i=t.length;r!==i;++r){var n=t[r];--n.useCount===0&&(n.restoreOriginalState(),this._takeBackBinding(n))}this._takeBackAction(e)}},_initMemoryManager:function(){this._actions=[],this._nActiveActions=0,this._actionsByClip={},this._bindings=[],this._nActiveBindings=0,this._bindingsByRootAndName={},this._controlInterpolants=[],this._nActiveControlInterpolants=0;var e=this;this.stats={actions:{get total(){return e._actions.length},get inUse(){return e._nActiveActions}},bindings:{get total(){return e._bindings.length},get inUse(){return e._nActiveBindings}},controlInterpolants:{get total(){return e._controlInterpolants.length},get inUse(){return e._nActiveControlInterpolants}}}},_isActiveAction:function(e){var t=e._cacheIndex;return t!==null&&t<this._nActiveActions},_addInactiveAction:function(e,t,r){var i=this._actions,n=this._actionsByClip,a=n[t];if(a===void 0)a={knownActions:[e],actionByRoot:{}},e._byClipCacheIndex=0,n[t]=a;else{var s=a.knownActions;e._byClipCacheIndex=s.length,s.push(e)}e._cacheIndex=i.length,i.push(e),a.actionByRoot[r]=e},_removeInactiveAction:function(e){var t=this._actions,r=t[t.length-1],i=e._cacheIndex;r._cacheIndex=i,t[i]=r,t.pop(),e._cacheIndex=null;var n=e._clip.uuid,a=this._actionsByClip,s=a[n],o=s.knownActions,h=o[o.length-1],c=e._byClipCacheIndex;h._byClipCacheIndex=c,o[c]=h,o.pop(),e._byClipCacheIndex=null;var u=s.actionByRoot,l=(e._localRoot||this._root).uuid;delete u[l],o.length===0&&delete a[n],this._removeInactiveBindingsForAction(e)},_removeInactiveBindingsForAction:function(e){for(var t=e._propertyBindings,r=0,i=t.length;r!==i;++r){var n=t[r];--n.referenceCount===0&&this._removeInactiveBinding(n)}},_lendAction:function(e){var t=this._actions,r=e._cacheIndex,i=this._nActiveActions++,n=t[i];e._cacheIndex=i,t[i]=e,n._cacheIndex=r,t[r]=n},_takeBackAction:function(e){var t=this._actions,r=e._cacheIndex,i=--this._nActiveActions,n=t[i];e._cacheIndex=i,t[i]=e,n._cacheIndex=r,t[r]=n},_addInactiveBinding:function(e,t,r){var i=this._bindingsByRootAndName,n=i[t],a=this._bindings;n===void 0&&(n={},i[t]=n),n[r]=e,e._cacheIndex=a.length,a.push(e)},_removeInactiveBinding:function(e){var t=this._bindings,r=e.binding,i=r.rootNode.uuid,n=r.path,a=this._bindingsByRootAndName,s=a[i],o=t[t.length-1],h=e._cacheIndex;o._cacheIndex=h,t[h]=o,t.pop(),delete s[n];e:{for(var c in s)break e;delete a[i]}},_lendBinding:function(e){var t=this._bindings,r=e._cacheIndex,i=this._nActiveBindings++,n=t[i];e._cacheIndex=i,t[i]=e,n._cacheIndex=r,t[r]=n},_takeBackBinding:function(e){var t=this._bindings,r=e._cacheIndex,i=--this._nActiveBindings,n=t[i];e._cacheIndex=i,t[i]=e,n._cacheIndex=r,t[r]=n},_lendControlInterpolant:function(){var e=this._controlInterpolants,t=this._nActiveControlInterpolants++,r=e[t];return r===void 0&&(r=new Pn(new Float32Array(2),new Float32Array(2),1,this._controlInterpolantsResultBuffer),r.__cacheIndex=t,e[t]=r),r},_takeBackControlInterpolant:function(e){var t=this._controlInterpolants,r=e.__cacheIndex,i=--this._nActiveControlInterpolants,n=t[i];e.__cacheIndex=i,t[i]=e,n.__cacheIndex=r,t[r]=n},_controlInterpolantsResultBuffer:new Float32Array(1),clipAction:function(e,t){var r=t||this._root,i=r.uuid,n=typeof e=="string"?Ct.findByName(r,e):e,a=n!==null?n.uuid:e,s=this._actionsByClip[a],o=null;if(s!==void 0){var h=s.actionByRoot[i];if(h!==void 0)return h;o=s.knownActions[0],n===null&&(n=o._clip)}if(n===null)return null;var c=new Ho(this,n,t);return this._bindAction(c,o),this._addInactiveAction(c,a,i),c},existingAction:function(e,t){var r=t||this._root,i=r.uuid,n=typeof e=="string"?Ct.findByName(r,e):e,a=n?n.uuid:e,s=this._actionsByClip[a];return s!==void 0&&s.actionByRoot[i]||null},stopAllAction:function(){var e=this._actions,t=this._nActiveActions,r=this._bindings,i=this._nActiveBindings;this._nActiveActions=0,this._nActiveBindings=0;for(var n=0;n!==t;++n)e[n].reset();for(var n=0;n!==i;++n)r[n].useCount=0;return this},update:function(e){e*=this.timeScale;for(var t=this._actions,r=this._nActiveActions,i=this.time+=e,n=Math.sign(e),a=this._accuIndex^=1,s=0;s!==r;++s){var o=t[s];o._update(i,e,n,a)}for(var h=this._bindings,c=this._nActiveBindings,s=0;s!==c;++s)h[s].apply(a);return this},getRoot:function(){return this._root},uncacheClip:function(e){var t=this._actions,r=e.uuid,i=this._actionsByClip,n=i[r];if(n!==void 0){for(var a=n.knownActions,s=0,o=a.length;s!==o;++s){var h=a[s];this._deactivateAction(h);var c=h._cacheIndex,u=t[t.length-1];h._cacheIndex=null,h._byClipCacheIndex=null,u._cacheIndex=c,t[c]=u,t.pop(),this._removeInactiveBindingsForAction(h)}delete i[r]}},uncacheRoot:function(e){var t=e.uuid,r=this._actionsByClip;for(var i in r){var n=r[i].actionByRoot,a=n[t];a!==void 0&&(this._deactivateAction(a),this._removeInactiveAction(a))}var s=this._bindingsByRootAndName,o=s[t];if(o!==void 0)for(var h in o){var c=o[h];c.restoreOriginalState(),this._removeInactiveBinding(c)}},uncacheAction:function(e,t){var r=this.existingAction(e,t);r!==null&&(this._deactivateAction(r),this._removeInactiveAction(r))}});function Ga(e){typeof e=="string"&&(console.warn("THREE.Uniform: Type parameter is no longer needed."),e=arguments[1]),this.value=e}Ga.prototype.clone=function(){return new Ga(this.value.clone===void 0?this.value:this.value.clone())};function zs(){$.call(this),this.type="InstancedBufferGeometry",this.maxInstancedCount=void 0}zs.prototype=Object.assign(Object.create($.prototype),{constructor:zs,isInstancedBufferGeometry:!0,copy:function(e){return $.prototype.copy.call(this,e),this.maxInstancedCount=e.maxInstancedCount,this},clone:function(){return new this.constructor().copy(this)}});function Hs(e,t,r){Lr.call(this,e,t),this.meshPerAttribute=r||1}Hs.prototype=Object.assign(Object.create(Lr.prototype),{constructor:Hs,isInstancedInterleavedBuffer:!0,copy:function(e){return Lr.prototype.copy.call(this,e),this.meshPerAttribute=e.meshPerAttribute,this}});function Vs(e,t,r,i){typeof r=="number"&&(i=r,r=!1,console.error("THREE.InstancedBufferAttribute: The constructor now expects normalized as the third argument.")),xe.call(this,e,t,r),this.meshPerAttribute=i||1}Vs.prototype=Object.assign(Object.create(xe.prototype),{constructor:Vs,isInstancedBufferAttribute:!0,copy:function(e){return xe.prototype.copy.call(this,e),this.meshPerAttribute=e.meshPerAttribute,this}});function vd(e,t,r,i){this.ray=new jr(e,t),this.near=r||0,this.far=i||1/0,this.params={Mesh:{},Line:{},LOD:{},Points:{threshold:1},Sprite:{}},Object.defineProperties(this.params,{PointCloud:{get:function(){return console.warn("THREE.Raycaster: params.PointCloud has been renamed to params.Points."),this.Points}}})}function ks(e,t){return e.distance-t.distance}function za(e,t,r,i){if(e.visible!==!1&&(e.raycast(t,r),i===!0))for(var n=e.children,a=0,s=n.length;a<s;a++)za(n[a],t,r,!0)}Object.assign(vd.prototype,{linePrecision:1,set:function(e,t){this.ray.set(e,t)},setFromCamera:function(e,t){t&&t.isPerspectiveCamera?(this.ray.origin.setFromMatrixPosition(t.matrixWorld),this.ray.direction.set(e.x,e.y,.5).unproject(t).sub(this.ray.origin).normalize()):t&&t.isOrthographicCamera?(this.ray.origin.set(e.x,e.y,(t.near+t.far)/(t.near-t.far)).unproject(t),this.ray.direction.set(0,0,-1).transformDirection(t.matrixWorld)):console.error("THREE.Raycaster: Unsupported camera type.")},intersectObject:function(e,t,r){var i=r||[];return za(e,this,i,t),i.sort(ks),i},intersectObjects:function(e,t,r){var i=r||[];if(Array.isArray(e)===!1)return console.warn("THREE.Raycaster.intersectObjects: objects is not an Array."),i;for(var n=0,a=e.length;n<a;n++)za(e[n],this,i,t);return i.sort(ks),i}});function gd(e,t,r){return this.radius=e!==void 0?e:1,this.phi=t!==void 0?t:0,this.theta=r!==void 0?r:0,this}Object.assign(gd.prototype,{set:function(e,t,r){return this.radius=e,this.phi=t,this.theta=r,this},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.radius=e.radius,this.phi=e.phi,this.theta=e.theta,this},makeSafe:function(){var e=1e-6;return this.phi=Math.max(e,Math.min(Math.PI-e,this.phi)),this},setFromVector3:function(e){return this.setFromCartesianCoords(e.x,e.y,e.z)},setFromCartesianCoords:function(e,t,r){return this.radius=Math.sqrt(e*e+t*t+r*r),this.radius===0?(this.theta=0,this.phi=0):(this.theta=Math.atan2(e,r),this.phi=Math.acos(ge.clamp(t/this.radius,-1,1))),this}});function yd(e,t,r){return this.radius=e!==void 0?e:1,this.theta=t!==void 0?t:0,this.y=r!==void 0?r:0,this}Object.assign(yd.prototype,{set:function(e,t,r){return this.radius=e,this.theta=t,this.y=r,this},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.radius=e.radius,this.theta=e.theta,this.y=e.y,this},setFromVector3:function(e){return this.setFromCartesianCoords(e.x,e.y,e.z)},setFromCartesianCoords:function(e,t,r){return this.radius=Math.sqrt(e*e+r*r),this.theta=Math.atan2(e,r),this.y=t,this}});function Vo(e,t){this.min=e!==void 0?e:new z(1/0,1/0),this.max=t!==void 0?t:new z(-1/0,-1/0)}Object.assign(Vo.prototype,{set:function(e,t){return this.min.copy(e),this.max.copy(t),this},setFromPoints:function(e){this.makeEmpty();for(var t=0,r=e.length;t<r;t++)this.expandByPoint(e[t]);return this},setFromCenterAndSize:function(){var e=new z;return function(r,i){var n=e.copy(i).multiplyScalar(.5);return this.min.copy(r).sub(n),this.max.copy(r).add(n),this}}(),clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.min.copy(e.min),this.max.copy(e.max),this},makeEmpty:function(){return this.min.x=this.min.y=1/0,this.max.x=this.max.y=-1/0,this},isEmpty:function(){return this.max.x<this.min.x||this.max.y<this.min.y},getCenter:function(e){return e===void 0&&(console.warn("THREE.Box2: .getCenter() target is now required"),e=new z),this.isEmpty()?e.set(0,0):e.addVectors(this.min,this.max).multiplyScalar(.5)},getSize:function(e){return e===void 0&&(console.warn("THREE.Box2: .getSize() target is now required"),e=new z),this.isEmpty()?e.set(0,0):e.subVectors(this.max,this.min)},expandByPoint:function(e){return this.min.min(e),this.max.max(e),this},expandByVector:function(e){return this.min.sub(e),this.max.add(e),this},expandByScalar:function(e){return this.min.addScalar(-e),this.max.addScalar(e),this},containsPoint:function(e){return!(e.x<this.min.x||e.x>this.max.x||e.y<this.min.y||e.y>this.max.y)},containsBox:function(e){return this.min.x<=e.min.x&&e.max.x<=this.max.x&&this.min.y<=e.min.y&&e.max.y<=this.max.y},getParameter:function(e,t){return t===void 0&&(console.warn("THREE.Box2: .getParameter() target is now required"),t=new z),t.set((e.x-this.min.x)/(this.max.x-this.min.x),(e.y-this.min.y)/(this.max.y-this.min.y))},intersectsBox:function(e){return!(e.max.x<this.min.x||e.min.x>this.max.x||e.max.y<this.min.y||e.min.y>this.max.y)},clampPoint:function(e,t){return t===void 0&&(console.warn("THREE.Box2: .clampPoint() target is now required"),t=new z),t.copy(e).clamp(this.min,this.max)},distanceToPoint:function(){var e=new z;return function(r){var i=e.copy(r).clamp(this.min,this.max);return i.sub(r).length()}}(),intersect:function(e){return this.min.max(e.min),this.max.min(e.max),this},union:function(e){return this.min.min(e.min),this.max.max(e.max),this},translate:function(e){return this.min.add(e),this.max.add(e),this},equals:function(e){return e.min.equals(this.min)&&e.max.equals(this.max)}});function ko(e,t){this.start=e!==void 0?e:new b,this.end=t!==void 0?t:new b}Object.assign(ko.prototype,{set:function(e,t){return this.start.copy(e),this.end.copy(t),this},clone:function(){return new this.constructor().copy(this)},copy:function(e){return this.start.copy(e.start),this.end.copy(e.end),this},getCenter:function(e){return e===void 0&&(console.warn("THREE.Line3: .getCenter() target is now required"),e=new b),e.addVectors(this.start,this.end).multiplyScalar(.5)},delta:function(e){return e===void 0&&(console.warn("THREE.Line3: .delta() target is now required"),e=new b),e.subVectors(this.end,this.start)},distanceSq:function(){return this.start.distanceToSquared(this.end)},distance:function(){return this.start.distanceTo(this.end)},at:function(e,t){return t===void 0&&(console.warn("THREE.Line3: .at() target is now required"),t=new b),this.delta(t).multiplyScalar(e).add(this.start)},closestPointToPointParameter:function(){var e=new b,t=new b;return function(i,n){e.subVectors(i,this.start),t.subVectors(this.end,this.start);var a=t.dot(t),s=t.dot(e),o=s/a;return n&&(o=ge.clamp(o,0,1)),o}}(),closestPointToPoint:function(e,t,r){var i=this.closestPointToPointParameter(e,t);return r===void 0&&(console.warn("THREE.Line3: .closestPointToPoint() target is now required"),r=new b),this.delta(r).multiplyScalar(i).add(this.start)},applyMatrix4:function(e){return this.start.applyMatrix4(e),this.end.applyMatrix4(e),this},equals:function(e){return e.start.equals(this.start)&&e.end.equals(this.end)}});function On(e){K.call(this),this.material=e,this.render=function(){}}On.prototype=Object.create(K.prototype);On.prototype.constructor=On;On.prototype.isImmediateRenderObject=!0;function Fn(e,t,r,i){this.object=e,this.size=t!==void 0?t:1;var n=r!==void 0?r:16711680,a=i!==void 0?i:1,s=0,o=this.object.geometry;o&&o.isGeometry?s=o.faces.length*3:o&&o.isBufferGeometry&&(s=o.attributes.normal.count);var h=new $,c=new Z(s*2*3,3);h.addAttribute("position",c),Ge.call(this,h,new Ne({color:n,linewidth:a})),this.matrixAutoUpdate=!1,this.update()}Fn.prototype=Object.create(Ge.prototype);Fn.prototype.constructor=Fn;Fn.prototype.update=function(){var e=new b,t=new b,r=new nt;return function(){var n=["a","b","c"];this.object.updateMatrixWorld(!0),r.getNormalMatrix(this.object.matrixWorld);var a=this.object.matrixWorld,s=this.geometry.attributes.position,o=this.object.geometry;if(o&&o.isGeometry)for(var h=o.vertices,c=o.faces,u=0,l=0,f=c.length;l<f;l++)for(var d=c[l],p=0,m=d.vertexNormals.length;p<m;p++){var v=h[d[n[p]]],g=d.vertexNormals[p];e.copy(v).applyMatrix4(a),t.copy(g).applyMatrix3(r).normalize().multiplyScalar(this.size).add(e),s.setXYZ(u,e.x,e.y,e.z),u=u+1,s.setXYZ(u,t.x,t.y,t.z),u=u+1}else if(o&&o.isBufferGeometry)for(var _=o.attributes.position,w=o.attributes.normal,u=0,p=0,m=_.count;p<m;p++)e.set(_.getX(p),_.getY(p),_.getZ(p)).applyMatrix4(a),t.set(w.getX(p),w.getY(p),w.getZ(p)),t.applyMatrix3(r).normalize().multiplyScalar(this.size).add(e),s.setXYZ(u,e.x,e.y,e.z),u=u+1,s.setXYZ(u,t.x,t.y,t.z),u=u+1;s.needsUpdate=!0}}();function Ci(e,t){K.call(this),this.light=e,this.light.updateMatrixWorld(),this.matrix=e.matrixWorld,this.matrixAutoUpdate=!1,this.color=t;for(var r=new $,i=[0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,-1,0,1,0,0,0,0,1,1,0,0,0,0,-1,1],n=0,a=1,s=32;n<s;n++,a++){var o=n/s*Math.PI*2,h=a/s*Math.PI*2;i.push(Math.cos(o),Math.sin(o),1,Math.cos(h),Math.sin(h),1)}r.addAttribute("position",new Z(i,3));var c=new Ne({fog:!1});this.cone=new Ge(r,c),this.add(this.cone),this.update()}Ci.prototype=Object.create(K.prototype);Ci.prototype.constructor=Ci;Ci.prototype.dispose=function(){this.cone.geometry.dispose(),this.cone.material.dispose()};Ci.prototype.update=function(){var e=new b;return function(){this.light.updateMatrixWorld();var r=this.light.distance?this.light.distance:1e3,i=r*Math.tan(this.light.angle);this.cone.scale.set(i,i,r),e.setFromMatrixPosition(this.light.target.matrixWorld),this.cone.lookAt(e),this.color!==void 0?this.cone.material.color.set(this.color):this.cone.material.color.copy(this.light.color)}}();function Wo(e){var t=[];e&&e.isBone&&t.push(e);for(var r=0;r<e.children.length;r++)t.push.apply(t,Wo(e.children[r]));return t}function Ii(e){for(var t=Wo(e),r=new $,i=[],n=[],a=new oe(0,0,1),s=new oe(0,1,0),o=0;o<t.length;o++){var h=t[o];h.parent&&h.parent.isBone&&(i.push(0,0,0),i.push(0,0,0),n.push(a.r,a.g,a.b),n.push(s.r,s.g,s.b))}r.addAttribute("position",new Z(i,3)),r.addAttribute("color",new Z(n,3));var c=new Ne({vertexColors:Wr,depthTest:!1,depthWrite:!1,transparent:!0});Ge.call(this,r,c),this.root=e,this.bones=t,this.matrix=e.matrixWorld,this.matrixAutoUpdate=!1}Ii.prototype=Object.create(Ge.prototype);Ii.prototype.constructor=Ii;Ii.prototype.updateMatrixWorld=function(){var e=new b,t=new fe,r=new fe;return function(n){var a=this.bones,s=this.geometry,o=s.getAttribute("position");r.getInverse(this.root.matrixWorld);for(var h=0,c=0;h<a.length;h++){var u=a[h];u.parent&&u.parent.isBone&&(t.multiplyMatrices(r,u.matrixWorld),e.setFromMatrixPosition(t),o.setXYZ(c,e.x,e.y,e.z),t.multiplyMatrices(r,u.parent.matrixWorld),e.setFromMatrixPosition(t),o.setXYZ(c+1,e.x,e.y,e.z),c+=2)}s.getAttribute("position").needsUpdate=!0,K.prototype.updateMatrixWorld.call(this,n)}}();function Di(e,t,r){this.light=e,this.light.updateMatrixWorld(),this.color=r;var i=new Ir(t,4,2),n=new St({wireframe:!0,fog:!1});lt.call(this,i,n),this.matrix=this.light.matrixWorld,this.matrixAutoUpdate=!1,this.update()}Di.prototype=Object.create(lt.prototype);Di.prototype.constructor=Di;Di.prototype.dispose=function(){this.geometry.dispose(),this.material.dispose()};Di.prototype.update=function(){this.color!==void 0?this.material.color.set(this.color):this.material.color.copy(this.light.color)};function Oi(e,t){this.type="RectAreaLightHelper",this.light=e,this.color=t;var r=[1,1,0,-1,1,0,-1,-1,0,1,-1,0,1,1,0],i=new $;i.addAttribute("position",new Z(r,3)),i.computeBoundingSphere();var n=new Ne({fog:!1});vt.call(this,i,n);var a=[1,1,0,-1,1,0,-1,-1,0,1,1,0,-1,-1,0,1,-1,0],s=new $;s.addAttribute("position",new Z(a,3)),s.computeBoundingSphere(),this.add(new lt(s,new St({side:THREE.BackSide,fog:!1}))),this.update()}Oi.prototype=Object.create(vt.prototype);Oi.prototype.constructor=Oi;Oi.prototype.update=function(){if(this.scale.set(.5*this.light.width,.5*this.light.height,1),this.color!==void 0)this.material.color.set(this.color),this.children[0].material.color.set(this.color);else{this.material.color.copy(this.light.color).multiplyScalar(this.light.intensity);var e=this.material.color,t=Math.max(e.r,e.g,e.b);t>1&&e.multiplyScalar(1/t),this.children[0].material.color.copy(this.material.color)}};Oi.prototype.dispose=function(){this.geometry.dispose(),this.material.dispose(),this.children[0].geometry.dispose(),this.children[0].material.dispose()};function Fi(e,t,r){K.call(this),this.light=e,this.light.updateMatrixWorld(),this.matrix=e.matrixWorld,this.matrixAutoUpdate=!1,this.color=r;var i=new Pr(t);i.rotateY(Math.PI*.5),this.material=new St({wireframe:!0,fog:!1}),this.color===void 0&&(this.material.vertexColors=Wr);var n=i.getAttribute("position"),a=new Float32Array(n.count*3);i.addAttribute("color",new xe(a,3)),this.add(new lt(i,this.material)),this.update()}Fi.prototype=Object.create(K.prototype);Fi.prototype.constructor=Fi;Fi.prototype.dispose=function(){this.children[0].geometry.dispose(),this.children[0].material.dispose()};Fi.prototype.update=function(){var e=new b,t=new oe,r=new oe;return function(){var n=this.children[0];if(this.color!==void 0)this.material.color.set(this.color);else{var a=n.geometry.getAttribute("color");t.copy(this.light.color),r.copy(this.light.groundColor);for(var s=0,o=a.count;s<o;s++){var h=s<o/2?t:r;a.setXYZ(s,h.r,h.g,h.b)}a.needsUpdate=!0}n.lookAt(e.setFromMatrixPosition(this.light.matrixWorld).negate())}}();function Un(e,t,r,i){e=e||10,t=t||10,r=new oe(r!==void 0?r:4473924),i=new oe(i!==void 0?i:8947848);for(var n=t/2,a=e/t,s=e/2,o=[],h=[],c=0,u=0,l=-s;c<=t;c++,l+=a){o.push(-s,0,l,s,0,l),o.push(l,0,-s,l,0,s);var f=c===n?r:i;f.toArray(h,u),u+=3,f.toArray(h,u),u+=3,f.toArray(h,u),u+=3,f.toArray(h,u),u+=3}var d=new $;d.addAttribute("position",new Z(o,3)),d.addAttribute("color",new Z(h,3));var p=new Ne({vertexColors:Wr});Ge.call(this,d,p)}Un.prototype=Object.create(Ge.prototype);Un.prototype.constructor=Un;function Ha(e,t,r,i,n,a){e=e||10,t=t||16,r=r||8,i=i||64,n=new oe(n!==void 0?n:4473924),a=new oe(a!==void 0?a:8947848);var s=[],o=[],h,c,u,l,f,d,p;for(l=0;l<=t;l++)u=l/t*(Math.PI*2),h=Math.sin(u)*e,c=Math.cos(u)*e,s.push(0,0,0),s.push(h,0,c),p=l&1?n:a,o.push(p.r,p.g,p.b),o.push(p.r,p.g,p.b);for(l=0;l<=r;l++)for(p=l&1?n:a,d=e-e/r*l,f=0;f<i;f++)u=f/i*(Math.PI*2),h=Math.sin(u)*d,c=Math.cos(u)*d,s.push(h,0,c),o.push(p.r,p.g,p.b),u=(f+1)/i*(Math.PI*2),h=Math.sin(u)*d,c=Math.cos(u)*d,s.push(h,0,c),o.push(p.r,p.g,p.b);var m=new $;m.addAttribute("position",new Z(s,3)),m.addAttribute("color",new Z(o,3));var v=new Ne({vertexColors:Wr});Ge.call(this,m,v)}Ha.prototype=Object.create(Ge.prototype);Ha.prototype.constructor=Ha;function Bn(e,t,r,i){this.object=e,this.size=t!==void 0?t:1;var n=r!==void 0?r:16776960,a=i!==void 0?i:1,s=0,o=this.object.geometry;o&&o.isGeometry?s=o.faces.length:console.warn("THREE.FaceNormalsHelper: only THREE.Geometry is supported. Use THREE.VertexNormalsHelper, instead.");var h=new $,c=new Z(s*2*3,3);h.addAttribute("position",c),Ge.call(this,h,new Ne({color:n,linewidth:a})),this.matrixAutoUpdate=!1,this.update()}Bn.prototype=Object.create(Ge.prototype);Bn.prototype.constructor=Bn;Bn.prototype.update=function(){var e=new b,t=new b,r=new nt;return function(){this.object.updateMatrixWorld(!0),r.getNormalMatrix(this.object.matrixWorld);for(var n=this.object.matrixWorld,a=this.geometry.attributes.position,s=this.object.geometry,o=s.vertices,h=s.faces,c=0,u=0,l=h.length;u<l;u++){var f=h[u],d=f.normal;e.copy(o[f.a]).add(o[f.b]).add(o[f.c]).divideScalar(3).applyMatrix4(n),t.copy(d).applyMatrix3(r).normalize().multiplyScalar(this.size).add(e),a.setXYZ(c,e.x,e.y,e.z),c=c+1,a.setXYZ(c,t.x,t.y,t.z),c=c+1}a.needsUpdate=!0}}();function Ui(e,t,r){K.call(this),this.light=e,this.light.updateMatrixWorld(),this.matrix=e.matrixWorld,this.matrixAutoUpdate=!1,this.color=r,t===void 0&&(t=1);var i=new $;i.addAttribute("position",new Z([-t,t,0,t,t,0,t,-t,0,-t,-t,0,-t,t,0],3));var n=new Ne({fog:!1});this.lightPlane=new vt(i,n),this.add(this.lightPlane),i=new $,i.addAttribute("position",new Z([0,0,0,0,0,1],3)),this.targetLine=new vt(i,n),this.add(this.targetLine),this.update()}Ui.prototype=Object.create(K.prototype);Ui.prototype.constructor=Ui;Ui.prototype.dispose=function(){this.lightPlane.geometry.dispose(),this.lightPlane.material.dispose(),this.targetLine.geometry.dispose(),this.targetLine.material.dispose()};Ui.prototype.update=function(){var e=new b,t=new b,r=new b;return function(){e.setFromMatrixPosition(this.light.matrixWorld),t.setFromMatrixPosition(this.light.target.matrixWorld),r.subVectors(t,e),this.lightPlane.lookAt(t),this.color!==void 0?(this.lightPlane.material.color.set(this.color),this.targetLine.material.color.set(this.color)):(this.lightPlane.material.color.copy(this.light.color),this.targetLine.material.color.copy(this.light.color)),this.targetLine.lookAt(t),this.targetLine.scale.z=r.length()}}();function Nn(e){var t=new $,r=new Ne({color:16777215,vertexColors:Ys}),i=[],n=[],a={},s=new oe(16755200),o=new oe(16711680),h=new oe(43775),c=new oe(16777215),u=new oe(3355443);l("n1","n2",s),l("n2","n4",s),l("n4","n3",s),l("n3","n1",s),l("f1","f2",s),l("f2","f4",s),l("f4","f3",s),l("f3","f1",s),l("n1","f1",s),l("n2","f2",s),l("n3","f3",s),l("n4","f4",s),l("p","n1",o),l("p","n2",o),l("p","n3",o),l("p","n4",o),l("u1","u2",h),l("u2","u3",h),l("u3","u1",h),l("c","t",c),l("p","c",u),l("cn1","cn2",u),l("cn3","cn4",u),l("cf1","cf2",u),l("cf3","cf4",u);function l(d,p,m){f(d,m),f(p,m)}function f(d,p){i.push(0,0,0),n.push(p.r,p.g,p.b),a[d]===void 0&&(a[d]=[]),a[d].push(i.length/3-1)}t.addAttribute("position",new Z(i,3)),t.addAttribute("color",new Z(n,3)),Ge.call(this,t,r),this.camera=e,this.camera.updateProjectionMatrix&&this.camera.updateProjectionMatrix(),this.matrix=e.matrixWorld,this.matrixAutoUpdate=!1,this.pointMap=a,this.update()}Nn.prototype=Object.create(Ge.prototype);Nn.prototype.constructor=Nn;Nn.prototype.update=function(){var e,t,r=new b,i=new Xt;function n(a,s,o,h){r.set(s,o,h).unproject(i);var c=t[a];if(c!==void 0)for(var u=e.getAttribute("position"),l=0,f=c.length;l<f;l++)u.setXYZ(c[l],r.x,r.y,r.z)}return function(){e=this.geometry,t=this.pointMap;var s=1,o=1;i.projectionMatrix.copy(this.camera.projectionMatrix),n("c",0,0,-1),n("t",0,0,1),n("n1",-s,-o,-1),n("n2",s,-o,-1),n("n3",-s,o,-1),n("n4",s,o,-1),n("f1",-s,-o,1),n("f2",s,-o,1),n("f3",-s,o,1),n("f4",s,o,1),n("u1",s*.7,o*1.1,-1),n("u2",-s*.7,o*1.1,-1),n("u3",0,o*2,-1),n("cf1",-s,0,1),n("cf2",s,0,1),n("cf3",0,-o,1),n("cf4",0,o,1),n("cn1",-s,0,-1),n("cn2",s,0,-1),n("cn3",0,-o,-1),n("cn4",0,o,-1),e.getAttribute("position").needsUpdate=!0}}();function vr(e,t){this.object=e,t===void 0&&(t=16776960);var r=new Uint16Array([0,1,1,2,2,3,3,0,4,5,5,6,6,7,7,4,0,4,1,5,2,6,3,7]),i=new Float32Array(8*3),n=new $;n.setIndex(new xe(r,1)),n.addAttribute("position",new xe(i,3)),Ge.call(this,n,new Ne({color:t})),this.matrixAutoUpdate=!1,this.update()}vr.prototype=Object.create(Ge.prototype);vr.prototype.constructor=vr;vr.prototype.update=function(){var e=new tr;return function(r){if(r!==void 0&&console.warn("THREE.BoxHelper: .update() has no longer arguments."),this.object!==void 0&&e.setFromObject(this.object),!e.isEmpty()){var i=e.min,n=e.max,a=this.geometry.attributes.position,s=a.array;s[0]=n.x,s[1]=n.y,s[2]=n.z,s[3]=i.x,s[4]=n.y,s[5]=n.z,s[6]=i.x,s[7]=i.y,s[8]=n.z,s[9]=n.x,s[10]=i.y,s[11]=n.z,s[12]=n.x,s[13]=n.y,s[14]=i.z,s[15]=i.x,s[16]=n.y,s[17]=i.z,s[18]=i.x,s[19]=i.y,s[20]=i.z,s[21]=n.x,s[22]=i.y,s[23]=i.z,a.needsUpdate=!0,this.geometry.computeBoundingSphere()}}}();vr.prototype.setFromObject=function(e){return this.object=e,this.update(),this};vr.prototype.copy=function(e){return Ge.prototype.copy.call(this,e),this.object=e.object,this};vr.prototype.clone=function(){return new this.constructor().copy(this)};function Gn(e,t){this.type="Box3Helper",this.box=e;var r=t!==void 0?t:16776960,i=new Uint16Array([0,1,1,2,2,3,3,0,4,5,5,6,6,7,7,4,0,4,1,5,2,6,3,7]),n=[1,1,1,-1,1,1,-1,-1,1,1,-1,1,1,1,-1,-1,1,-1,-1,-1,-1,1,-1,-1],a=new $;a.setIndex(new xe(i,1)),a.addAttribute("position",new Z(n,3)),Ge.call(this,a,new Ne({color:r})),this.geometry.computeBoundingSphere()}Gn.prototype=Object.create(Ge.prototype);Gn.prototype.constructor=Gn;Gn.prototype.updateMatrixWorld=function(e){var t=this.box;t.isEmpty()||(t.getCenter(this.position),t.getSize(this.scale),this.scale.multiplyScalar(.5),K.prototype.updateMatrixWorld.call(this,e))};function zn(e,t,r){this.type="PlaneHelper",this.plane=e,this.size=t===void 0?1:t;var i=r!==void 0?r:16776960,n=[1,-1,1,-1,1,1,-1,-1,1,1,1,1,-1,1,1,-1,-1,1,1,-1,1,1,1,1,0,0,1,0,0,0],a=new $;a.addAttribute("position",new Z(n,3)),a.computeBoundingSphere(),vt.call(this,a,new Ne({color:i}));var s=[1,1,1,-1,1,1,-1,-1,1,1,1,1,-1,-1,1,1,-1,1],o=new $;o.addAttribute("position",new Z(s,3)),o.computeBoundingSphere(),this.add(new lt(o,new St({color:i,opacity:.2,transparent:!0,depthWrite:!1})))}zn.prototype=Object.create(vt.prototype);zn.prototype.constructor=zn;zn.prototype.updateMatrixWorld=function(e){var t=-this.plane.constant;Math.abs(t)<1e-8&&(t=1e-8),this.scale.set(.5*this.size,.5*this.size,t),this.children[0].material.side=t<0?st:Bi,this.lookAt(this.plane.normal),K.prototype.updateMatrixWorld.call(this,e)};var qi,aa;function nr(e,t,r,i,n,a){K.call(this),e===void 0&&(e=new THREE.Vector3(0,0,1)),t===void 0&&(t=new THREE.Vector3(0,0,0)),r===void 0&&(r=1),i===void 0&&(i=16776960),n===void 0&&(n=.2*r),a===void 0&&(a=.2*n),qi===void 0&&(qi=new $,qi.addAttribute("position",new Z([0,0,0,0,1,0],3)),aa=new ir(0,.5,1,5,1),aa.translate(0,-.5,0)),this.position.copy(t),this.line=new vt(qi,new Ne({color:i})),this.line.matrixAutoUpdate=!1,this.add(this.line),this.cone=new lt(aa,new St({color:i})),this.cone.matrixAutoUpdate=!1,this.add(this.cone),this.setDirection(e),this.setLength(r,n,a)}nr.prototype=Object.create(K.prototype);nr.prototype.constructor=nr;nr.prototype.setDirection=function(){var e=new b,t;return function(i){i.y>.99999?this.quaternion.set(0,0,0,1):i.y<-.99999?this.quaternion.set(1,0,0,0):(e.set(i.z,0,-i.x).normalize(),t=Math.acos(i.y),this.quaternion.setFromAxisAngle(e,t))}}();nr.prototype.setLength=function(e,t,r){t===void 0&&(t=.2*e),r===void 0&&(r=.2*t),this.line.scale.set(1,Math.max(0,e-t),1),this.line.updateMatrix(),this.cone.scale.set(r,t,r),this.cone.position.y=e,this.cone.updateMatrix()};nr.prototype.setColor=function(e){this.line.material.color.copy(e),this.cone.material.color.copy(e)};nr.prototype.copy=function(e){return K.prototype.copy.call(this,e,!1),this.line.copy(e.line),this.cone.copy(e.cone),this};nr.prototype.clone=function(){return new this.constructor().copy(this)};function Va(e){e=e||1;var t=[0,0,0,e,0,0,0,0,0,0,e,0,0,0,0,0,0,e],r=[1,0,0,1,.6,0,0,1,0,.6,1,0,0,0,1,0,.6,1],i=new $;i.addAttribute("position",new Z(t,3)),i.addAttribute("color",new Z(r,3));var n=new Ne({vertexColors:Wr});Ge.call(this,i,n)}Va.prototype=Object.create(Ge.prototype);Va.prototype.constructor=Va;ce.create=function(e,t){return e.prototype=Object.create(ce.prototype),e.prototype.constructor=e,e.prototype.getPoint=t,e};Object.assign(Kt.prototype,{createPointsGeometry:function(e){console.warn("THREE.CurvePath: .createPointsGeometry() has been removed. Use new THREE.Geometry().setFromPoints( points ) instead.");var t=this.getPoints(e);return this.createGeometry(t)},createSpacedPointsGeometry:function(e){console.warn("THREE.CurvePath: .createSpacedPointsGeometry() has been removed. Use new THREE.Geometry().setFromPoints( points ) instead.");var t=this.getSpacedPoints(e);return this.createGeometry(t)},createGeometry:function(e){console.warn("THREE.CurvePath: .createGeometry() has been removed. Use new THREE.Geometry().setFromPoints( points ) instead.");for(var t=new de,r=0,i=e.length;r<i;r++){var n=e[r];t.vertices.push(new b(n.x,n.y,n.z||0))}return t}});Object.assign(It.prototype,{fromPoints:function(e){console.warn("THREE.Path: .fromPoints() has been renamed to .setFromPoints()."),this.setFromPoints(e)}});Object.create(wt.prototype);Object.create(wt.prototype);function Xo(e){console.warn("THREE.Spline has been removed. Use THREE.CatmullRomCurve3 instead."),wt.call(this,e),this.type="catmullrom"}Xo.prototype=Object.create(wt.prototype);Object.assign(Xo.prototype,{initFromArray:function(){console.error("THREE.Spline: .initFromArray() has been removed.")},getControlPointsArray:function(){console.error("THREE.Spline: .getControlPointsArray() has been removed.")},reparametrizeByArcLength:function(){console.error("THREE.Spline: .reparametrizeByArcLength() has been removed.")}});Un.prototype.setColors=function(){console.error("THREE.GridHelper: setColors() has been deprecated, pass them in the constructor instead.")};Ii.prototype.update=function(){console.error("THREE.SkeletonHelper: update() no longer needs to be called.")};Object.assign(In.prototype,{extractUrlBase:function(e){return console.warn("THREE.Loader: .extractUrlBase() has been deprecated. Use THREE.LoaderUtils.extractUrlBase() instead."),Po.extractUrlBase(e)}});Object.assign(Io.prototype,{setTexturePath:function(e){return console.warn("THREE.ObjectLoader: .setTexturePath() has been renamed to .setResourcePath()."),this.setResourcePath(e)}});Object.assign(Vo.prototype,{center:function(e){return console.warn("THREE.Box2: .center() has been renamed to .getCenter()."),this.getCenter(e)},empty:function(){return console.warn("THREE.Box2: .empty() has been renamed to .isEmpty()."),this.isEmpty()},isIntersectionBox:function(e){return console.warn("THREE.Box2: .isIntersectionBox() has been renamed to .intersectsBox()."),this.intersectsBox(e)},size:function(e){return console.warn("THREE.Box2: .size() has been renamed to .getSize()."),this.getSize(e)}});Object.assign(tr.prototype,{center:function(e){return console.warn("THREE.Box3: .center() has been renamed to .getCenter()."),this.getCenter(e)},empty:function(){return console.warn("THREE.Box3: .empty() has been renamed to .isEmpty()."),this.isEmpty()},isIntersectionBox:function(e){return console.warn("THREE.Box3: .isIntersectionBox() has been renamed to .intersectsBox()."),this.intersectsBox(e)},isIntersectionSphere:function(e){return console.warn("THREE.Box3: .isIntersectionSphere() has been renamed to .intersectsSphere()."),this.intersectsSphere(e)},size:function(e){return console.warn("THREE.Box3: .size() has been renamed to .getSize()."),this.getSize(e)}});ko.prototype.center=function(e){return console.warn("THREE.Line3: .center() has been renamed to .getCenter()."),this.getCenter(e)};Object.assign(ge,{random16:function(){return console.warn("THREE.Math: .random16() has been deprecated. Use Math.random() instead."),Math.random()},nearestPowerOfTwo:function(e){return console.warn("THREE.Math: .nearestPowerOfTwo() has been renamed to .floorPowerOfTwo()."),ge.floorPowerOfTwo(e)},nextPowerOfTwo:function(e){return console.warn("THREE.Math: .nextPowerOfTwo() has been renamed to .ceilPowerOfTwo()."),ge.ceilPowerOfTwo(e)}});Object.assign(nt.prototype,{flattenToArrayOffset:function(e,t){return console.warn("THREE.Matrix3: .flattenToArrayOffset() has been deprecated. Use .toArray() instead."),this.toArray(e,t)},multiplyVector3:function(e){return console.warn("THREE.Matrix3: .multiplyVector3() has been removed. Use vector.applyMatrix3( matrix ) instead."),e.applyMatrix3(this)},multiplyVector3Array:function(){console.error("THREE.Matrix3: .multiplyVector3Array() has been removed.")},applyToBuffer:function(e){return console.warn("THREE.Matrix3: .applyToBuffer() has been removed. Use matrix.applyToBufferAttribute( attribute ) instead."),this.applyToBufferAttribute(e)},applyToVector3Array:function(){console.error("THREE.Matrix3: .applyToVector3Array() has been removed.")}});Object.assign(fe.prototype,{extractPosition:function(e){return console.warn("THREE.Matrix4: .extractPosition() has been renamed to .copyPosition()."),this.copyPosition(e)},flattenToArrayOffset:function(e,t){return console.warn("THREE.Matrix4: .flattenToArrayOffset() has been deprecated. Use .toArray() instead."),this.toArray(e,t)},getPosition:function(){var e;return function(){return e===void 0&&(e=new b),console.warn("THREE.Matrix4: .getPosition() has been removed. Use Vector3.setFromMatrixPosition( matrix ) instead."),e.setFromMatrixColumn(this,3)}}(),setRotationFromQuaternion:function(e){return console.warn("THREE.Matrix4: .setRotationFromQuaternion() has been renamed to .makeRotationFromQuaternion()."),this.makeRotationFromQuaternion(e)},multiplyToArray:function(){console.warn("THREE.Matrix4: .multiplyToArray() has been removed.")},multiplyVector3:function(e){return console.warn("THREE.Matrix4: .multiplyVector3() has been removed. Use vector.applyMatrix4( matrix ) instead."),e.applyMatrix4(this)},multiplyVector4:function(e){return console.warn("THREE.Matrix4: .multiplyVector4() has been removed. Use vector.applyMatrix4( matrix ) instead."),e.applyMatrix4(this)},multiplyVector3Array:function(){console.error("THREE.Matrix4: .multiplyVector3Array() has been removed.")},rotateAxis:function(e){console.warn("THREE.Matrix4: .rotateAxis() has been removed. Use Vector3.transformDirection( matrix ) instead."),e.transformDirection(this)},crossVector:function(e){return console.warn("THREE.Matrix4: .crossVector() has been removed. Use vector.applyMatrix4( matrix ) instead."),e.applyMatrix4(this)},translate:function(){console.error("THREE.Matrix4: .translate() has been removed.")},rotateX:function(){console.error("THREE.Matrix4: .rotateX() has been removed.")},rotateY:function(){console.error("THREE.Matrix4: .rotateY() has been removed.")},rotateZ:function(){console.error("THREE.Matrix4: .rotateZ() has been removed.")},rotateByAxis:function(){console.error("THREE.Matrix4: .rotateByAxis() has been removed.")},applyToBuffer:function(e){return console.warn("THREE.Matrix4: .applyToBuffer() has been removed. Use matrix.applyToBufferAttribute( attribute ) instead."),this.applyToBufferAttribute(e)},applyToVector3Array:function(){console.error("THREE.Matrix4: .applyToVector3Array() has been removed.")},makeFrustum:function(e,t,r,i,n,a){return console.warn("THREE.Matrix4: .makeFrustum() has been removed. Use .makePerspective( left, right, top, bottom, near, far ) instead."),this.makePerspective(e,t,i,r,n,a)}});Vt.prototype.isIntersectionLine=function(e){return console.warn("THREE.Plane: .isIntersectionLine() has been renamed to .intersectsLine()."),this.intersectsLine(e)};Qe.prototype.multiplyVector3=function(e){return console.warn("THREE.Quaternion: .multiplyVector3() has been removed. Use is now vector.applyQuaternion( quaternion ) instead."),e.applyQuaternion(this)};Object.assign(jr.prototype,{isIntersectionBox:function(e){return console.warn("THREE.Ray: .isIntersectionBox() has been renamed to .intersectsBox()."),this.intersectsBox(e)},isIntersectionPlane:function(e){return console.warn("THREE.Ray: .isIntersectionPlane() has been renamed to .intersectsPlane()."),this.intersectsPlane(e)},isIntersectionSphere:function(e){return console.warn("THREE.Ray: .isIntersectionSphere() has been renamed to .intersectsSphere()."),this.intersectsSphere(e)}});Object.assign(ot.prototype,{area:function(){return console.warn("THREE.Triangle: .area() has been renamed to .getArea()."),this.getArea()},barycoordFromPoint:function(e,t){return console.warn("THREE.Triangle: .barycoordFromPoint() has been renamed to .getBarycoord()."),this.getBarycoord(e,t)},midpoint:function(e){return console.warn("THREE.Triangle: .midpoint() has been renamed to .getMidpoint()."),this.getMidpoint(e)},normal:function(e){return console.warn("THREE.Triangle: .normal() has been renamed to .getNormal()."),this.getNormal(e)},plane:function(e){return console.warn("THREE.Triangle: .plane() has been renamed to .getPlane()."),this.getPlane(e)}});Object.assign(ot,{barycoordFromPoint:function(e,t,r,i,n){return console.warn("THREE.Triangle: .barycoordFromPoint() has been renamed to .getBarycoord()."),ot.getBarycoord(e,t,r,i,n)},normal:function(e,t,r,i){return console.warn("THREE.Triangle: .normal() has been renamed to .getNormal()."),ot.getNormal(e,t,r,i)}});Object.assign(hr.prototype,{extractAllPoints:function(e){return console.warn("THREE.Shape: .extractAllPoints() has been removed. Use .extractPoints() instead."),this.extractPoints(e)},extrude:function(e){return console.warn("THREE.Shape: .extrude() has been removed. Use ExtrudeGeometry() instead."),new Cr(this,e)},makeGeometry:function(e){return console.warn("THREE.Shape: .makeGeometry() has been removed. Use ShapeGeometry() instead."),new Dr(this,e)}});Object.assign(z.prototype,{fromAttribute:function(e,t,r){return console.warn("THREE.Vector2: .fromAttribute() has been renamed to .fromBufferAttribute()."),this.fromBufferAttribute(e,t,r)},distanceToManhattan:function(e){return console.warn("THREE.Vector2: .distanceToManhattan() has been renamed to .manhattanDistanceTo()."),this.manhattanDistanceTo(e)},lengthManhattan:function(){return console.warn("THREE.Vector2: .lengthManhattan() has been renamed to .manhattanLength()."),this.manhattanLength()}});Object.assign(b.prototype,{setEulerFromRotationMatrix:function(){console.error("THREE.Vector3: .setEulerFromRotationMatrix() has been removed. Use Euler.setFromRotationMatrix() instead.")},setEulerFromQuaternion:function(){console.error("THREE.Vector3: .setEulerFromQuaternion() has been removed. Use Euler.setFromQuaternion() instead.")},getPositionFromMatrix:function(e){return console.warn("THREE.Vector3: .getPositionFromMatrix() has been renamed to .setFromMatrixPosition()."),this.setFromMatrixPosition(e)},getScaleFromMatrix:function(e){return console.warn("THREE.Vector3: .getScaleFromMatrix() has been renamed to .setFromMatrixScale()."),this.setFromMatrixScale(e)},getColumnFromMatrix:function(e,t){return console.warn("THREE.Vector3: .getColumnFromMatrix() has been renamed to .setFromMatrixColumn()."),this.setFromMatrixColumn(t,e)},applyProjection:function(e){return console.warn("THREE.Vector3: .applyProjection() has been removed. Use .applyMatrix4( m ) instead."),this.applyMatrix4(e)},fromAttribute:function(e,t,r){return console.warn("THREE.Vector3: .fromAttribute() has been renamed to .fromBufferAttribute()."),this.fromBufferAttribute(e,t,r)},distanceToManhattan:function(e){return console.warn("THREE.Vector3: .distanceToManhattan() has been renamed to .manhattanDistanceTo()."),this.manhattanDistanceTo(e)},lengthManhattan:function(){return console.warn("THREE.Vector3: .lengthManhattan() has been renamed to .manhattanLength()."),this.manhattanLength()}});Object.assign(Fe.prototype,{fromAttribute:function(e,t,r){return console.warn("THREE.Vector4: .fromAttribute() has been renamed to .fromBufferAttribute()."),this.fromBufferAttribute(e,t,r)},lengthManhattan:function(){return console.warn("THREE.Vector4: .lengthManhattan() has been renamed to .manhattanLength()."),this.manhattanLength()}});Object.assign(de.prototype,{computeTangents:function(){console.error("THREE.Geometry: .computeTangents() has been removed.")},computeLineDistances:function(){console.error("THREE.Geometry: .computeLineDistances() has been removed. Use THREE.Line.computeLineDistances() instead.")}});Object.assign(K.prototype,{getChildByName:function(e){return console.warn("THREE.Object3D: .getChildByName() has been renamed to .getObjectByName()."),this.getObjectByName(e)},renderDepth:function(){console.warn("THREE.Object3D: .renderDepth has been removed. Use .renderOrder, instead.")},translate:function(e,t){return console.warn("THREE.Object3D: .translate() has been removed. Use .translateOnAxis( axis, distance ) instead."),this.translateOnAxis(t,e)},getWorldRotation:function(){console.error("THREE.Object3D: .getWorldRotation() has been removed. Use THREE.Object3D.getWorldQuaternion( target ) instead.")}});Object.defineProperties(K.prototype,{eulerOrder:{get:function(){return console.warn("THREE.Object3D: .eulerOrder is now .rotation.order."),this.rotation.order},set:function(e){console.warn("THREE.Object3D: .eulerOrder is now .rotation.order."),this.rotation.order=e}},useQuaternion:{get:function(){console.warn("THREE.Object3D: .useQuaternion has been removed. The library now uses quaternions by default.")},set:function(){console.warn("THREE.Object3D: .useQuaternion has been removed. The library now uses quaternions by default.")}}});Object.defineProperties(on.prototype,{objects:{get:function(){return console.warn("THREE.LOD: .objects has been renamed to .levels."),this.levels}}});Object.defineProperty(_a.prototype,"useVertexTexture",{get:function(){console.warn("THREE.Skeleton: useVertexTexture has been removed.")},set:function(){console.warn("THREE.Skeleton: useVertexTexture has been removed.")}});hn.prototype.initBones=function(){console.error("THREE.SkinnedMesh: initBones() has been removed.")};Object.defineProperty(ce.prototype,"__arcLengthDivisions",{get:function(){return console.warn("THREE.Curve: .__arcLengthDivisions is now .arcLengthDivisions."),this.arcLengthDivisions},set:function(e){console.warn("THREE.Curve: .__arcLengthDivisions is now .arcLengthDivisions."),this.arcLengthDivisions=e}});je.prototype.setLens=function(e,t){console.warn("THREE.PerspectiveCamera.setLens is deprecated. Use .setFocalLength and .filmGauge for a photographic setup."),t!==void 0&&(this.filmGauge=t),this.setFocalLength(e)};Object.defineProperties(ke.prototype,{onlyShadow:{set:function(){console.warn("THREE.Light: .onlyShadow has been removed.")}},shadowCameraFov:{set:function(e){console.warn("THREE.Light: .shadowCameraFov is now .shadow.camera.fov."),this.shadow.camera.fov=e}},shadowCameraLeft:{set:function(e){console.warn("THREE.Light: .shadowCameraLeft is now .shadow.camera.left."),this.shadow.camera.left=e}},shadowCameraRight:{set:function(e){console.warn("THREE.Light: .shadowCameraRight is now .shadow.camera.right."),this.shadow.camera.right=e}},shadowCameraTop:{set:function(e){console.warn("THREE.Light: .shadowCameraTop is now .shadow.camera.top."),this.shadow.camera.top=e}},shadowCameraBottom:{set:function(e){console.warn("THREE.Light: .shadowCameraBottom is now .shadow.camera.bottom."),this.shadow.camera.bottom=e}},shadowCameraNear:{set:function(e){console.warn("THREE.Light: .shadowCameraNear is now .shadow.camera.near."),this.shadow.camera.near=e}},shadowCameraFar:{set:function(e){console.warn("THREE.Light: .shadowCameraFar is now .shadow.camera.far."),this.shadow.camera.far=e}},shadowCameraVisible:{set:function(){console.warn("THREE.Light: .shadowCameraVisible has been removed. Use new THREE.CameraHelper( light.shadow.camera ) instead.")}},shadowBias:{set:function(e){console.warn("THREE.Light: .shadowBias is now .shadow.bias."),this.shadow.bias=e}},shadowDarkness:{set:function(){console.warn("THREE.Light: .shadowDarkness has been removed.")}},shadowMapWidth:{set:function(e){console.warn("THREE.Light: .shadowMapWidth is now .shadow.mapSize.width."),this.shadow.mapSize.width=e}},shadowMapHeight:{set:function(e){console.warn("THREE.Light: .shadowMapHeight is now .shadow.mapSize.height."),this.shadow.mapSize.height=e}}});Object.defineProperties(xe.prototype,{length:{get:function(){return console.warn("THREE.BufferAttribute: .length has been deprecated. Use .count instead."),this.array.length}},copyIndicesArray:function(){console.error("THREE.BufferAttribute: .copyIndicesArray() has been removed.")}});Object.assign($.prototype,{addIndex:function(e){console.warn("THREE.BufferGeometry: .addIndex() has been renamed to .setIndex()."),this.setIndex(e)},addDrawCall:function(e,t,r){r!==void 0&&console.warn("THREE.BufferGeometry: .addDrawCall() no longer supports indexOffset."),console.warn("THREE.BufferGeometry: .addDrawCall() is now .addGroup()."),this.addGroup(e,t)},clearDrawCalls:function(){console.warn("THREE.BufferGeometry: .clearDrawCalls() is now .clearGroups()."),this.clearGroups()},computeTangents:function(){console.warn("THREE.BufferGeometry: .computeTangents() has been removed.")},computeOffsets:function(){console.warn("THREE.BufferGeometry: .computeOffsets() has been removed.")}});Object.defineProperties($.prototype,{drawcalls:{get:function(){return console.error("THREE.BufferGeometry: .drawcalls has been renamed to .groups."),this.groups}},offsets:{get:function(){return console.warn("THREE.BufferGeometry: .offsets has been renamed to .groups."),this.groups}}});Object.assign(jt.prototype,{getArrays:function(){console.error("THREE.ExtrudeBufferGeometry: .getArrays() has been removed.")},addShapeList:function(){console.error("THREE.ExtrudeBufferGeometry: .addShapeList() has been removed.")},addShape:function(){console.error("THREE.ExtrudeBufferGeometry: .addShape() has been removed.")}});Object.defineProperties(Ga.prototype,{dynamic:{set:function(){console.warn("THREE.Uniform: .dynamic has been removed. Use object.onBeforeRender() instead.")}},onUpdate:{value:function(){return console.warn("THREE.Uniform: .onUpdate() has been removed. Use object.onBeforeRender() instead."),this}}});Object.defineProperties(ve.prototype,{wrapAround:{get:function(){console.warn("THREE.Material: .wrapAround has been removed.")},set:function(){console.warn("THREE.Material: .wrapAround has been removed.")}},overdraw:{get:function(){console.warn("THREE.Material: .overdraw has been removed.")},set:function(){console.warn("THREE.Material: .overdraw has been removed.")}},wrapRGB:{get:function(){return console.warn("THREE.Material: .wrapRGB has been removed."),new oe}},shading:{get:function(){console.error("THREE."+this.type+": .shading has been removed. Use the boolean .flatShading instead.")},set:function(e){console.warn("THREE."+this.type+": .shading has been removed. Use the boolean .flatShading instead."),this.flatShading=e===js}}});Object.defineProperties(Ft.prototype,{metal:{get:function(){return console.warn("THREE.MeshPhongMaterial: .metal has been removed. Use THREE.MeshStandardMaterial instead."),!1},set:function(){console.warn("THREE.MeshPhongMaterial: .metal has been removed. Use THREE.MeshStandardMaterial instead")}}});Object.defineProperties(xt.prototype,{derivatives:{get:function(){return console.warn("THREE.ShaderMaterial: .derivatives has been moved to .extensions.derivatives."),this.extensions.derivatives},set:function(e){console.warn("THREE. ShaderMaterial: .derivatives has been moved to .extensions.derivatives."),this.extensions.derivatives=e}}});Object.assign(Ka.prototype,{clearTarget:function(e,t,r,i){console.warn("THREE.WebGLRenderer: .clearTarget() has been deprecated. Use .setRenderTarget() and .clear() instead."),this.setRenderTarget(e),this.clear(t,r,i)},animate:function(e){console.warn("THREE.WebGLRenderer: .animate() is now .setAnimationLoop()."),this.setAnimationLoop(e)},getCurrentRenderTarget:function(){return console.warn("THREE.WebGLRenderer: .getCurrentRenderTarget() is now .getRenderTarget()."),this.getRenderTarget()},getMaxAnisotropy:function(){return console.warn("THREE.WebGLRenderer: .getMaxAnisotropy() is now .capabilities.getMaxAnisotropy()."),this.capabilities.getMaxAnisotropy()},getPrecision:function(){return console.warn("THREE.WebGLRenderer: .getPrecision() is now .capabilities.precision."),this.capabilities.precision},resetGLState:function(){return console.warn("THREE.WebGLRenderer: .resetGLState() is now .state.reset()."),this.state.reset()},supportsFloatTextures:function(){return console.warn("THREE.WebGLRenderer: .supportsFloatTextures() is now .extensions.get( 'OES_texture_float' )."),this.extensions.get("OES_texture_float")},supportsHalfFloatTextures:function(){return console.warn("THREE.WebGLRenderer: .supportsHalfFloatTextures() is now .extensions.get( 'OES_texture_half_float' )."),this.extensions.get("OES_texture_half_float")},supportsStandardDerivatives:function(){return console.warn("THREE.WebGLRenderer: .supportsStandardDerivatives() is now .extensions.get( 'OES_standard_derivatives' )."),this.extensions.get("OES_standard_derivatives")},supportsCompressedTextureS3TC:function(){return console.warn("THREE.WebGLRenderer: .supportsCompressedTextureS3TC() is now .extensions.get( 'WEBGL_compressed_texture_s3tc' )."),this.extensions.get("WEBGL_compressed_texture_s3tc")},supportsCompressedTexturePVRTC:function(){return console.warn("THREE.WebGLRenderer: .supportsCompressedTexturePVRTC() is now .extensions.get( 'WEBGL_compressed_texture_pvrtc' )."),this.extensions.get("WEBGL_compressed_texture_pvrtc")},supportsBlendMinMax:function(){return console.warn("THREE.WebGLRenderer: .supportsBlendMinMax() is now .extensions.get( 'EXT_blend_minmax' )."),this.extensions.get("EXT_blend_minmax")},supportsVertexTextures:function(){return console.warn("THREE.WebGLRenderer: .supportsVertexTextures() is now .capabilities.vertexTextures."),this.capabilities.vertexTextures},supportsInstancedArrays:function(){return console.warn("THREE.WebGLRenderer: .supportsInstancedArrays() is now .extensions.get( 'ANGLE_instanced_arrays' )."),this.extensions.get("ANGLE_instanced_arrays")},enableScissorTest:function(e){console.warn("THREE.WebGLRenderer: .enableScissorTest() is now .setScissorTest()."),this.setScissorTest(e)},initMaterial:function(){console.warn("THREE.WebGLRenderer: .initMaterial() has been removed.")},addPrePlugin:function(){console.warn("THREE.WebGLRenderer: .addPrePlugin() has been removed.")},addPostPlugin:function(){console.warn("THREE.WebGLRenderer: .addPostPlugin() has been removed.")},updateShadowMap:function(){console.warn("THREE.WebGLRenderer: .updateShadowMap() has been removed.")},setFaceCulling:function(){console.warn("THREE.WebGLRenderer: .setFaceCulling() has been removed.")}});Object.defineProperties(Ka.prototype,{shadowMapEnabled:{get:function(){return this.shadowMap.enabled},set:function(e){console.warn("THREE.WebGLRenderer: .shadowMapEnabled is now .shadowMap.enabled."),this.shadowMap.enabled=e}},shadowMapType:{get:function(){return this.shadowMap.type},set:function(e){console.warn("THREE.WebGLRenderer: .shadowMapType is now .shadowMap.type."),this.shadowMap.type=e}},shadowMapCullFace:{get:function(){console.warn("THREE.WebGLRenderer: .shadowMapCullFace has been removed. Set Material.shadowSide instead.")},set:function(){console.warn("THREE.WebGLRenderer: .shadowMapCullFace has been removed. Set Material.shadowSide instead.")}}});Object.defineProperties(xo.prototype,{cullFace:{get:function(){console.warn("THREE.WebGLRenderer: .shadowMap.cullFace has been removed. Set Material.shadowSide instead.")},set:function(){console.warn("THREE.WebGLRenderer: .shadowMap.cullFace has been removed. Set Material.shadowSide instead.")}},renderReverseSided:{get:function(){console.warn("THREE.WebGLRenderer: .shadowMap.renderReverseSided has been removed. Set Material.shadowSide instead.")},set:function(){console.warn("THREE.WebGLRenderer: .shadowMap.renderReverseSided has been removed. Set Material.shadowSide instead.")}},renderSingleSided:{get:function(){console.warn("THREE.WebGLRenderer: .shadowMap.renderSingleSided has been removed. Set Material.shadowSide instead.")},set:function(){console.warn("THREE.WebGLRenderer: .shadowMap.renderSingleSided has been removed. Set Material.shadowSide instead.")}}});Object.defineProperties(Dt.prototype,{wrapS:{get:function(){return console.warn("THREE.WebGLRenderTarget: .wrapS is now .texture.wrapS."),this.texture.wrapS},set:function(e){console.warn("THREE.WebGLRenderTarget: .wrapS is now .texture.wrapS."),this.texture.wrapS=e}},wrapT:{get:function(){return console.warn("THREE.WebGLRenderTarget: .wrapT is now .texture.wrapT."),this.texture.wrapT},set:function(e){console.warn("THREE.WebGLRenderTarget: .wrapT is now .texture.wrapT."),this.texture.wrapT=e}},magFilter:{get:function(){return console.warn("THREE.WebGLRenderTarget: .magFilter is now .texture.magFilter."),this.texture.magFilter},set:function(e){console.warn("THREE.WebGLRenderTarget: .magFilter is now .texture.magFilter."),this.texture.magFilter=e}},minFilter:{get:function(){return console.warn("THREE.WebGLRenderTarget: .minFilter is now .texture.minFilter."),this.texture.minFilter},set:function(e){console.warn("THREE.WebGLRenderTarget: .minFilter is now .texture.minFilter."),this.texture.minFilter=e}},anisotropy:{get:function(){return console.warn("THREE.WebGLRenderTarget: .anisotropy is now .texture.anisotropy."),this.texture.anisotropy},set:function(e){console.warn("THREE.WebGLRenderTarget: .anisotropy is now .texture.anisotropy."),this.texture.anisotropy=e}},offset:{get:function(){return console.warn("THREE.WebGLRenderTarget: .offset is now .texture.offset."),this.texture.offset},set:function(e){console.warn("THREE.WebGLRenderTarget: .offset is now .texture.offset."),this.texture.offset=e}},repeat:{get:function(){return console.warn("THREE.WebGLRenderTarget: .repeat is now .texture.repeat."),this.texture.repeat},set:function(e){console.warn("THREE.WebGLRenderTarget: .repeat is now .texture.repeat."),this.texture.repeat=e}},format:{get:function(){return console.warn("THREE.WebGLRenderTarget: .format is now .texture.format."),this.texture.format},set:function(e){console.warn("THREE.WebGLRenderTarget: .format is now .texture.format."),this.texture.format=e}},type:{get:function(){return console.warn("THREE.WebGLRenderTarget: .type is now .texture.type."),this.texture.type},set:function(e){console.warn("THREE.WebGLRenderTarget: .type is now .texture.type."),this.texture.type=e}},generateMipmaps:{get:function(){return console.warn("THREE.WebGLRenderTarget: .generateMipmaps is now .texture.generateMipmaps."),this.texture.generateMipmaps},set:function(e){console.warn("THREE.WebGLRenderTarget: .generateMipmaps is now .texture.generateMipmaps."),this.texture.generateMipmaps=e}}});Object.defineProperties(wo.prototype,{standing:{set:function(){console.warn("THREE.WebVRManager: .standing has been removed.")}},userHeight:{set:function(){console.warn("THREE.WebVRManager: .userHeight has been removed.")}}});Pi.prototype.load=function(e){console.warn("THREE.Audio: .load has been deprecated. Use THREE.AudioLoader instead.");var t=this,r=new Uo;return r.load(e,function(i){t.setBuffer(i)}),this};No.prototype.getData=function(){return console.warn("THREE.AudioAnalyser: .getData() is now .getFrequencyData()."),this.getFrequencyData()};Dn.prototype.updateCubeMap=function(e,t){return console.warn("THREE.CubeCamera: .updateCubeMap() is now .update()."),this.update(e,t)};ur.crossOrigin=void 0;ur.loadTexture=function(e,t,r,i){console.warn("THREE.ImageUtils.loadTexture has been deprecated. Use THREE.TextureLoader() instead.");var n=new $a;n.setCrossOrigin(this.crossOrigin);var a=n.load(e,r,void 0,i);return t&&(a.mapping=t),a};ur.loadTextureCube=function(e,t,r,i){console.warn("THREE.ImageUtils.loadTextureCube has been deprecated. Use THREE.CubeTextureLoader() instead.");var n=new Lo;n.setCrossOrigin(this.crossOrigin);var a=n.load(e,r,void 0,i);return t&&(a.mapping=t),a};ur.loadCompressedTexture=function(){console.error("THREE.ImageUtils.loadCompressedTexture has been removed. Use THREE.DDSLoader instead.")};ur.loadCompressedTextureCube=function(){console.error("THREE.ImageUtils.loadCompressedTextureCube has been removed. Use THREE.DDSLoader instead.")};var Ws=0,xd=0;const _d="/api/upload",wd="file";function bd(e){const t=atob(e.split(",")[1]),r=e.split(",")[0].split(":")[1].split(";")[0],i=new ArrayBuffer(t.length),n=new Uint8Array(i);for(let a=0;a<t.length;a++)n[a]=t.charCodeAt(a);return new Blob([i],{type:r})}class Md{constructor(t={}){this.uploadUrl=t.uploadUrl||_d,this.uploadField=t.uploadField||wd,this.width=t.width||600,this.height=t.height||688,this.isolated=t.isolated===!0,this.domId=this.isolated?`three-game-render-${++xd}`:"three-game-render",this.captureRegion=t.captureRegion||null,this.isolated||(window.innerHeight=this.height,window.innerWidth=this.width),this.animationId=null,this.isDestroyed=!1,this.isAnimated=!1,this.initializeRenderer(),this.setupEventListeners(),this.startAnimation()}initializeRenderer(){this.cameraRTT=new Ri(this.width/-2,this.width/2,this.height/2,this.height/-2,-1e4,1e4),this.cameraRTT.position.z=0,this.updateCameraViewOffset(),this.sceneRTT=new an,this.createRenderTarget(),this.createGameTexture(),this.createMaterial(),this.createQuad(),this.renderer=new Ka({antialias:!1,preserveDrawingBuffer:!0}),this.renderer.setSize(this.width,this.height),this.renderer.autoClear=!1,this.createDOMElement()}createRenderTarget(){this.rtTexture&&this.rtTexture.dispose(),this.rtTexture=new Dt(this.width,this.height,{minFilter:it,magFilter:et,format:Wt,type:kn})}createGameTexture(){var t,r;this.gameTexture&&((r=(t=this.gameTexture).dispose)==null||r.call(t)),this.gameTexture=new Rr,this.gameTexture.needsUpdate=!0}createMaterial(){this.material&&this.material.dispose(),this.material=new xt({uniforms:{tDiffuse:{value:this.gameTexture}},vertexShader:`
                varying vec2 vUv;
                void main() {
                    vUv = vec2(uv.x, 1.0 - uv.y);
                    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                }
            `,fragmentShader:`
                varying vec2 vUv;
                uniform sampler2D tDiffuse;
                void main() {
                    gl_FragColor = texture2D(tDiffuse, vUv);
                }
            `})}createQuad(){this.quad&&(this.quad.geometry&&this.quad.geometry.dispose(),this.sceneRTT.remove(this.quad));const t=new lr(this.width,this.height);this.quad=new lt(t,this.material),this.quad.position.z=-100,this.sceneRTT.add(this.quad)}createDOMElement(){const t=document.getElementById(this.domId);t&&t.remove();const r=document.createElement("div");r.id=this.domId,r.style.display="none",r.appendChild(this.renderer.domElement),document.body.append(r)}setupEventListeners(){this.resizeBinded=this.resize.bind(this),window.addEventListener("resize",this.resizeBinded)}updateCameraViewOffset(t=!1){if(this.captureRegion){const r=this.captureRegion,i=Math.max(1,Math.round(r.uSpan*this.width)),n=Math.max(1,Math.round(r.vSpan*this.height));let a=Math.round((r.centerU-r.uSpan/2)*this.width),s=Math.round((r.centerV-r.vSpan/2)*this.height);a=Math.min(Math.max(a,0),Math.max(this.width-i,0)),s=Math.min(Math.max(s,0),Math.max(this.height-n,0)),this.cameraRTT.setViewOffset(this.width,this.height,a,s,i,n);return}if(t)this.cameraRTT.setViewOffset(this.width,this.height,0,0,this.width,this.height);else{const i=Math.floor(this.height*33/68);this.cameraRTT.setViewOffset(this.width,this.height,100,0,i,this.height)}}resize(t=!1){this.isDestroyed||(this.updateCameraViewOffset(t),this.cameraRTT.left=this.width/-2,this.cameraRTT.right=this.width/2,this.cameraRTT.top=this.height/2,this.cameraRTT.bottom=this.height/-2,this.cameraRTT.updateProjectionMatrix(),this.createRenderTarget(),this.createQuad(),this.renderer.setSize(this.width,this.height))}startAnimation(){this.animate=this.animate.bind(this),this.animationId=requestAnimationFrame(this.animate)}animate(){this.isDestroyed||(this.animationId=requestAnimationFrame(this.animate),this.isAnimated&&this.renderFrame())}renderFrame(){if(this.isDestroyed||!this.renderer||!this.sceneRTT||!this.cameraRTT)return;this.renderer.clear(),this.renderer.render(this.sceneRTT,this.cameraRTT,this.rtTexture,!0);const t=new Uint8Array(this.width*this.height*4);this.renderer.readRenderTargetPixels(this.rtTexture,0,0,this.width,this.height,t),this.canvas||this.createTempCanvas(),this.updateCanvas(t)}async captureFrame(t={}){const r=t.mime||"image/jpeg",i=t.quality!==void 0?t.quality:.92,n=t.warmupFrames!==void 0?t.warmupFrames:6;this.isAnimated=!0,this.canvas||this.createTempCanvas();for(let a=0;a<n;a++)if(await new Promise(s=>requestAnimationFrame(s)),this.isDestroyed)return null;return this.renderFrame(),this.canvas.toDataURL(r,i)}updateCanvas(t){if(!this.canvas)return;this.canvas.width=this.width,this.canvas.height=this.height;const r=new Uint8ClampedArray(t.buffer),i=this.canvas.getContext("2d"),n=new ImageData(r,this.width,this.height);i.putImageData(n,0,0)}createTempCanvas(){this.canvas=document.createElement("canvas"),this.canvas.style.display="inline",this.isExternalCanvas=!1}renderToTarget(t){this.resize(!1),this.canvas=t,this.isExternalCanvas=!0,this.isAnimated=!0}async requestScreenshot(t=this.uploadUrl,r=this.uploadField){return new Promise(async i=>{try{this.createTempCanvas(),this.isAnimated=!0,await new Promise(h=>setTimeout(h,10));const n=this.canvas.toDataURL("image/jpeg",.92),a=new FormData;a.append(r,bd(n),`screenshot_${Ws}.png`);const o=await(await fetch(t,{method:"POST",mode:"cors",body:a})).json();o.attachments&&o.attachments.length>0?i(o.attachments[0].url):(console.error("Görüntü yüklenirken bir hata oluştu:",o.message||"Bilinmeyen hata"),i(!1))}catch(n){console.error("Screenshot işlemi sırasında hata:",n),i(!1)}finally{Ws++,this.isAnimated=!1,this.canvas&&(this.canvas.remove(),this.canvas=null)}})}stop(){this.isDestroyed=!0,this.isAnimated=!1,this.animationId&&(cancelAnimationFrame(this.animationId),this.animationId=null),this.resizeBinded&&(window.removeEventListener("resize",this.resizeBinded),this.resizeBinded=null),this.canvas&&(this.isExternalCanvas||this.canvas.remove(),this.canvas=null),this.isExternalCanvas=!1,this.disposeWebGLResources();const t=document.getElementById(this.domId);t&&t.remove(),console.warn("[GameRender] Render Stopped.")}disposeWebGLResources(){var t,r,i,n;if(this.material&&(this.material.dispose(),this.material=null),this.quad&&this.quad.geometry&&this.quad.geometry.dispose(),this.sceneRTT){for(;this.sceneRTT.children.length>0;){const a=this.sceneRTT.children[0];a.isMesh&&(a.geometry&&a.geometry.dispose(),a.material&&a.material!==this.material&&(Array.isArray(a.material)?a.material.forEach(s=>s.dispose()):a.material.dispose())),this.sceneRTT.remove(a)}this.sceneRTT=null}this.rtTexture&&(this.rtTexture.dispose(),this.rtTexture=null),this.gameTexture&&((r=(t=this.gameTexture).dispose)==null||r.call(t),this.gameTexture=null),this.renderer&&(this.renderer.dispose(),(n=(i=this.renderer).forceContextLoss)==null||n.call(i),this.renderer=null),this.cameraRTT=null,this.quad=null}}export{Md as GameRender};
