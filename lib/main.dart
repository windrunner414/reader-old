import 'package:flutter/material.dart';
import 'package:reader/page/reader/reader.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Reader(
      bookId: 1,
      bookName: '斗破苍穹',
      onDownload: (List<Chapter> c){},
      getChapterContent: (String id) async {
        if (id == '1') {
          await Future.delayed(Duration(seconds: 3));
          return '';
          return null;
          if (Random(DateTime.now().millisecondsSinceEpoch).nextInt(5) >= 3) return null;
          return '''“斗之力，三段！”
    望着测验魔石碑上面闪亮得甚至有些刺眼的五个大字，少年面无表情，唇角有着一抹自嘲，紧握的手掌，因为大力，而导致略微尖锐的指甲深深的刺进了掌心之，带来一阵阵钻心的疼痛…
    “萧炎，斗之力，三段！级别：低级！”测验魔石碑之旁，一位年男，看了一眼碑上所显示出来的信息，语气漠然的将之公布了出来…
    年男话刚刚脱口，便是不出意外的在人头汹涌的广场上带起了一阵嘲讽的骚动。
    “三段？嘿嘿，果然不出我所料，这个“天才”这一年又是在原地踏步！”
    “哎，这废物真是把家族的脸都给丢光了。”
    “要不是族长是他的父亲，这种废物，早就被驱赶出家族，任其自生自灭了，哪还有机会待在家族白吃白喝。”
    “唉，昔年那名闻乌坦城的天才少年，如今怎么落魄成这般模样了啊？”
    “谁知道呢，或许做了什么亏心事，惹得神灵降怒了吧…”
    周围传来的不屑嘲笑以及惋惜轻叹，落在那如木桩待在原地的少年耳，恍如一根根利刺狠狠的扎在心脏一般，让得少年呼吸微微急促。
    少年缓缓抬起头来，露出一张有些清秀的稚嫩脸庞，漆黑的眸木然的在周围那些嘲讽的同龄人身上扫过，少年嘴角的自嘲，似乎变得更加苦涩了。
    “这些人，都如此刻薄势力吗？或许是因为三年前他们曾经在自己面前露出过最谦卑的笑容，所以，如今想要讨还回去吧…”苦涩的一笑，萧炎落寞的转身，安静的回到了队伍的最后一排，孤单的身影，与周围的世界，有些格格不入。
    “下一个，萧媚！”
    听着测验人的喊声，一名少女快速的人群跑出，少女刚刚出场，附近的议论声便是小了许多，一双双略微火热的目光，牢牢的锁定着少女的脸颊…
    少女年龄不过十四左右，虽然并算不上绝色，不过那张稚气未脱的小脸，却是蕴含着淡淡的妩媚，清纯与妩媚，矛盾的集合，让得她成功的成为了全场瞩目的焦点…
    少女快步上前，小手轻车熟路的触摸着漆黑的魔石碑，然后缓缓闭上眼睛…
    在少女闭眼片刻之后，漆黑的魔石碑之上再次亮起了光芒…
    “斗之气：七段！”
    “萧媚，斗之气：七段！级别:高级！”
    “耶！”听着测验员所喊出的成绩，少女脸颊扬起了得意的笑容…
    “啧啧，七段斗之气，真了不起，按这进度，恐怕顶多只需要三年时间，她就能称为一名真正的斗者了吧…”
    “不愧是家族种级别的人物啊…”
    听着人群传来的一阵阵羡慕声，少女脸颊上的笑容更是多了几分，虚荣心，这是很多女孩都无法抗拒的诱惑…
    与平日里的几个姐妹互相笑谈着，萧媚的视线，忽然的透过周围的人群，停在了人群外的那一道孤单身影上…
    皱眉思虑了瞬间，萧媚还是打消了过去的念头，现在的两人，已经不在同一个阶层之上，以萧炎最近几年的表现，成年后，顶多只能作为家族的下层人员，而天赋优秀的她，则将会成为家族重点培养的强者，前途可以说是不可限量。
    “唉…”莫名的轻叹了一口气，萧媚脑忽然浮现出三年前那意气风发的少年，四岁练气，十岁拥有段斗之气，十一岁突破十段斗之气，成功凝聚斗之气旋，一跃成为家族百年之内最年轻的斗者！
    当初的少年，自信而且潜力无可估量，不知让得多少少女对其春心荡漾，当然，这也包括以前的萧媚。
    然而天才的道路，貌似总是曲折的，三年之前，这名声望达到巅峰的天才少年，却是突兀的接受到了有生以来最残酷的打击，不仅辛辛苦苦修炼十数载方才凝聚的斗之气旋，一夜之间，化为乌有，而且体内的斗之气，也是随着时间的流逝，变得诡异的越来越少。
    斗之气消失的直接结果，便是导致其实力不断的后退。
    从天才的神坛，一夜跌落到了连普通人都不如的地步，这种打击，让得少年从此失魂落魄，天才之名，也是逐渐的被不屑与嘲讽所替代。
    站的越高，摔得越狠，这次的跌落，或许就再也没有爬起的机会。
    “下一个，萧薰儿！”
    喧闹的人群，测试员的声音，再次响了起来。
    随着这有些清雅的名字响起，人群忽然的安静了下来，所有的视线，豁然转移。
    在众人视线汇聚之处，一位身着紫色衣裙的少女，正淡雅的站立，平静的稚嫩俏脸，并未因为众人的注目而改变分毫。
    少女清冷淡然的气质，犹如清莲初绽，小小年纪，却已初具脱俗气质，难以想象，日后若是长大，少女将会如何的倾国倾城…
    这名紫裙少女，论起美貌与气质来，比先前的萧媚，无疑还要更胜上几分，也难怪在场的众人都是这般动作。
    莲步微移，名为萧薰儿的少女行到魔石碑之前，小手伸出，镶着黑金丝的紫袖滑落而下，露出一截雪白娇嫩的皓腕，然后轻触着石碑…
    微微沉静，石碑之上，刺眼的光芒再次绽放。
    “斗之气：段！级别：高级！”
    望着石碑之上的字体，场陷入了一阵寂静。
    “…竟然到段了，真是恐怖！家族年轻一辈的第一人，恐怕非薰儿小姐莫属了。”寂静过后，周围的少年，都是不由自主的咽了一口唾沫，眼神充满敬畏…
    斗之气，每位斗者的必经之路，初阶斗之气分一至十段，当体内斗之气到达十段之时，便能凝聚斗之气旋，成为一名受人尊重的斗者！
    人群，萧媚皱着浅眉盯着石碑前的紫裙少女，脸颊上闪过一抹嫉妒…
    望着石碑上的信息，一旁的年测验员漠然的脸庞上竟然也是罕见的露出了一丝笑意，对着少女略微恭声道：“薰儿小姐，半年之后，你应该便能凝聚斗气之旋，如果你成功的话，那么以十四岁年龄成为一名真正的斗者，你是萧家百年内的第二人！”
    是的，第二人，那位第一人，便是褪去了天才光环的萧炎。
    “谢谢。”少女微微点了点头，平淡的小脸并未因为他的夸奖而出现喜悦，安静的回转过身，然后在众人炽热的注目，缓缓的行到了人群最后面的那颓废少年面前…
    “萧炎哥哥。”在经过少年身旁时，少女顿下了脚步，对着萧炎恭敬的弯了弯腰，美丽的俏脸上，居然露出了让周围少女为之嫉妒的清雅笑容。
    “我现在还有资格让你怎么叫么?”望着面前这颗已经成长为家族最璀璨的明珠，萧炎苦涩的道，她是在自己落魄后，极为少数还对自己依旧保持着尊敬的人。
    “萧炎哥哥，以前你曾经与薰儿说过，要能放下，才能拿起，提放自如，是自在人！”萧薰儿微笑着柔声道，略微稚嫩的嗓音，却是暖人心肺。
    “呵呵，自在人？我也只会说而已，你看我现在的模样，象自在人吗？而且…这世界，本来就不属于我。”萧炎自嘲的一笑，意兴阑珊的道。
    面对着萧炎的颓废，萧薰儿纤细的眉毛微微皱了皱，认真的道：“萧炎哥哥，虽然并不知道你究竟是怎么回事，不过，薰儿相信，你会重新站起来，取回属于你的荣耀与尊严…”话到此处，微顿了顿，少女白皙的俏脸，头一次露出淡淡的绯红：“当年的萧炎哥哥，的确很吸引人…”
    “呵呵…”面对着少女毫不掩饰的坦率话语，少年尴尬的笑了一声，可却未再说什么，人不风流枉少年，可现在的他，实在没这资格与心情，落寞的回转过身，对着广场之外缓缓行去…
    站在原地望着少年那恍如与世隔绝的孤独背影，萧薰儿踌躇了一会，然后在身后一干嫉妒的狼嚎声，快步追了上去，与少年并肩而行… ''';
        } else if (id == '2') {
          await Future.delayed(Duration(seconds: 3));
          return '''月如银盘，漫天繁星。
    山崖之颠，萧炎斜躺在草地之上，嘴叼一根青草，微微嚼动，任由那淡淡的苦涩在嘴弥漫开来…
    举起有些白皙的手掌，挡在眼前，目光透过手指缝隙，遥望着天空上那轮巨大的银月。
    “唉…”想起下午的测试，萧炎轻叹了一口气，懒懒的抽回手掌，双手枕着脑袋，眼神有些恍惚…
    “十五年了呢…”低低的自喃声，忽然毫无边际的从少年嘴轻吐了出来。
    在萧炎的心，有一个仅有他自己知道的秘密：他并不是这个世界的人，或者说，萧炎的灵魂，并不属于这个世界，他来自一个名叫地球的蔚蓝星球，至于为什么会来到这里，这种离奇经过，他也无法解释，不过在生活了一段时间之后，他还是后知后觉的明白了过来：他穿越了！
    随着年龄的增长，对这块大陆，萧炎也是有了些模糊的了解…
    大陆名为斗气大陆，大陆上并没有小说常见的各系魔法，而斗气，才是大陆的唯一主调！
    在这片大陆上，斗气的修炼，几乎已经在无数代人的努力之下，发展到了巅峰地步，而且由于斗气的不断繁衍，最后甚至扩散到了民间之，这也导致，斗气，与人类的日常生活，变得息息相关，如此，斗气在大陆的重要性，更是变得无可替代！
    因为斗气的极端繁衍，同时也导致从这条主线分化出了无数条斗气修炼之法，所谓手有长短，分化出来的斗气修炼之法，自然也是有强有弱。
    经过归纳统计，斗气大陆将斗气功法的等级，由高到低分为四阶十二级：天.地.玄.黄！
    而每一阶，又分初，，高三级！
    修炼的斗气功法等级的高低，也是决定日后成就高低的关键，比如修炼玄阶级功法的人，自然要比修炼黄阶高级功法的同等级的人要强上几分。
    斗气大陆，分辩强弱，取决于三种条件。
    首先，最重要的，当然是自身的实力，如果本身实力只有一星斗者级别，那就算你修炼的是天阶高级的稀世功法，那也难以战胜一名修炼黄阶功法的斗师。
    其次，便是功法！同等级的强者，如果你的功法等级较之对方要高级许多，那么在比试之时，种种优势，一触既知。
    最后一种，名叫斗技！
    顾名思义，这是一种发挥斗气的特殊技能，斗技在大陆之上，也有着等级之分，总的说来，同样也是分为天地玄黄四级。
    斗气大陆斗技数不胜数，不过一般流传出来的大众斗技，大多都只是黄级左右，想要获得更高深的斗技，便必须加入宗派，或者大陆上的斗气学院。
    当然，一些依靠奇遇所得到前人遗留而下的功法，或者有着自己相配套的斗技，这种由功法衍变而出的斗技，互相配合起来，威力要更强上一些。
    依靠这三种条件，方才能判出究竟孰强孰弱，总的说来，如果能够拥有等级偏高的斗气功法，日后的好处，不言而喻…
    不过高级斗气修炼功法常人很难得到，流传在普通阶层的功法，顶多只是黄阶功法，一些比较强大的家族或者小宗派，应该有玄阶的修炼之法，比如萧炎所在的家族，最为顶层的功法，便是只有族长才有资格修炼的：狂狮怒罡，这是一种风属性，并且是玄阶级的斗气功法。
    玄阶之上，便是地阶了，不过这种高深功法，或许便只有那些超然势力与大帝国，方才可能拥有…
    至于天阶…已经几百年未曾出现了。
    从理论上来说，常人想要获得高级功法，基本上是难如登天，然而事无绝对，斗气大陆地域辽阔，万族林立，大陆之北，有号称力大无穷，可与兽魂合体的蛮族，大陆之南，也有各种智商奇高的高级魔兽家族，更有那以诡异阴狠而著名的黑暗种族等等…
    由于地域的辽阔，也有很多不为人知的无名隐士，在生命走到尽头之后，性孤僻的他们，或许会将平生所创功法隐于某处，等待有缘人取之，在斗气大陆上，流传一句话：如果某日，你摔落悬崖，掉落山洞，不要惊慌，往前走两步，或许，你，将成为强者！
    此话，并不属假，大陆近千年历史，并不泛这种依靠奇遇而成为强者的故事.
    这个故事所造成的后果，便是造就了大批每天等在悬崖边，准备跳崖得绝世功法的怀梦之人，当然了，这些人大多都是以断胳膊断腿归来…
    总之，这是一片充满奇迹，以及创造奇迹的大陆！
    当然，想要修炼斗气秘籍，至少需要成为一名真正的斗者之后，方才够资格，而现在的萧炎隔那段距离，似乎还很是遥远…
    “呸。”吐出嘴的草根，萧炎忽然跳起身来，脸庞狰狞，对着夜空失态的咆哮道：“我草你***，把劳资穿过来当废物玩吗？草！”
    在前世，萧炎只是庸碌众生极其平凡的一员，金钱，美人，这些东西与他根本就是两条平行线，永远没有交叉点，然而，当来到这片斗气大陆之后，萧炎却是惊喜的发现，因为两世的经验，他的灵魂，竟然比常人要强上许多！
    要知道，在斗气大陆，灵魂是天生的，或许它能随着年龄的增长而稍稍变强，可却从没有什么功法能够单独修炼灵魂，就算是天阶功法，也不可能！这是斗气大陆的常识。
    灵魂的强化，也造就出萧炎的修炼天赋，同样，也造就了他的天才之名。
    当一个平凡庸碌之人，在知道他有成为无数人瞩目的本钱之后，若是没有足够的定力，很难能够把握本心，很显然的，前世仅仅是普通人的萧炎，并没有这种超人般的定力，所以，在他开始修炼斗之气后，他选择了成为受人瞩目的天才之路，而并非是在安静逐渐成长！
    若是没有意外发生的话，萧炎或许还真能够顶着天才的名头越长越大，不过，很可惜，在十一岁那年，天才之名，逐渐被突如其来的变故剥夺而去，而天才，也是在一夜间，沦落成了路人口嘲笑的废物！
    ……
    在咆哮了几嗓之后，萧炎的情绪也是缓缓的平息了下来，脸庞再次回复了平日的落寞，事与至此，不管他如何暴怒，也是挽不回辛苦修炼而来的斗之气旋。
    苦涩的摇了摇头，萧炎心其实有些委屈，毕竟他对自己身体究竟发生了什么事，也是一概不知，平日检查，却没有发现丝毫不对劲的地方，灵魂，随着年龄的增加，也是越来越强大，而且吸收斗之气的速度，比几年前最巅峰的状态还要强盛上几分，这种种条件，都说明自己的天赋从不曾减弱，可那些进入体内的斗之气，却都是无一例外的消失得干干净净，诡异的情形，让得萧炎黯然神伤…
    黯然的叹了口气，萧炎抬起手掌，手指上有一颗黑色戒指，戒指很是古朴，不知是何材料所铸，其上还绘有些模糊的纹路，这是母亲临死前送给他的唯一礼物，从四岁开始，他已经佩戴了十年，母亲的遗物，让得萧炎对它也是有着一份眷恋，手指轻轻的抚摸着戒指，萧炎苦笑道：“这几年，还真是辜负母亲的期望了…”
    深深的吐了一口气，萧炎忽然回转过头，对着漆黑的树林温暖的笑道：“父亲，您来了？”
    虽然斗之气只有三段，不过萧炎的灵魂感知，却是比一名五星斗者都要敏锐许多，在先前说起母亲的时候，他便察觉到了树林的一丝动静。
    “呵呵，炎儿，这么晚了，怎么还待在这上面呢？”树林，在静了片刻后，传出男的关切笑声。
    树枝一阵摇摆，一位年人跃了出来，脸庞上带着笑意，凝视着自己那站在月光下的儿。
    年人身着华贵的灰色衣衫，龙行虎步间颇有几分威严，脸上一对粗眉更是为其添了几分豪气，他便是萧家现任族长，同时也是萧炎的父亲，五星大斗师，萧战！
    “父亲，您不也还没休息么？”望着年男，萧炎脸庞上的笑容更浓了一分，虽然自己有着前世的记忆，不过自出生以来，面前这位父亲便是对自己百般宠爱，在自己落魄之后，宠爱不减反增，如此行径，却是让得萧炎甘心叫他一声父亲。
    “炎儿，还在想下午测验的事呢？”大步上前，萧战笑道。
    “呵呵，有什么好想的，意料之而已。”萧炎少年老成的摇了摇头，笑容却是有些勉强。
    “唉…”望着萧炎那依旧有些稚嫩的清秀脸庞，萧战叹了一口气，沉默了片刻，忽然道：“炎儿，你十五岁了吧？”
    “嗯，父亲。”
    “再有一年，似乎…就该进行成年仪式了…”萧战苦笑道。
    “是的，父亲，还有一年！”手掌微微一紧，萧炎平静的回道，成年仪式代表什么，他自然非常清楚，只要度过了成年仪式，那么没有修炼潜力的他，便将会被取消进入斗气阁寻找斗气功法的资格，从而被分配到家族的各处产业之，为家族打理一些普通事物，这是家族的族规，就算他的父亲是族长，那也不可能改变！
    毕竟，若是在二十五岁之前没有成为一名斗者，那将不会被家族所认可！
    “对不起了，炎儿，如果在一年后你的斗之气达不到七段，那么父亲也只得忍痛把你分配到家族的产业去，毕竟，这个家族，还并不是父亲一人说了算，那几个老家伙，可随时等着父亲犯错呢…”望着平静的萧炎，萧战有些歉疚的叹道。
    “父亲，我会努力的，一年后，我一定会到达七段斗之气的！”萧炎微笑着安慰道。
    “一年，四段？呵呵，如果是以前，或许还有可能吧，不过现在…基本没半点机会…”虽然口在安慰着父亲，不过萧炎心却是自嘲的苦笑了起来。
    同样非常清楚萧炎底细的萧战，也只得叹息着应了一声，他知道一年修炼四段斗之气有多困难，轻拍了拍他的脑袋，忽然笑道：“不早了，回去休息吧，明天，家族有贵客，你可别失了礼。”
    “贵客？谁啊？”萧炎好奇的问道。
    “明天就知道了.”对着萧炎挤了挤眼睛，萧战大笑而去，留下无奈的萧炎。
    “放心吧，父亲，我会尽力的！”抚摸着手指上的古朴戒指，萧炎抬头喃喃道。
    在萧炎抬头的那一刹，手指的黑色古戒，却是忽然亮起了一抹极其微弱的诡异毫光，毫光眨眼便逝，没有引起任何人的察觉… ''';
        } else {
          return null;
        }
      },
      getChapterList: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        List<Chapter> chapterList = [];
        for (var i = 0; i < 10000; ++i) {
          chapterList.addAll([
            Chapter(title: '第一章 陨落的天才', id: '1'),
            Chapter(title: '第二章 斗气大陆', id: '2'),
          ]);
        }
        return chapterList;
      },
    );
  }
}
