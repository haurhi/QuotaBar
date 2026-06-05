import Combine
import Foundation

struct AIQuote {
    let english: String
    let simplifiedChinese: String
    let traditionalChinese: String
    let japanese: String
    let korean: String

    func text(language: AppLanguage) -> String {
        switch language {
        case .english:
            return english
        case .simplifiedChinese:
            return simplifiedChinese
        case .traditionalChinese:
            return traditionalChinese
        case .japanese:
            return japanese
        case .korean:
            return korean
        }
    }
}

struct AIQuoteLibrary {
    static let quotes: [AIQuote] = [
        AIQuote(english: "Measure before you worry.", simplifiedChinese: "先看数字，再担心", traditionalChinese: "先看數字，再擔心", japanese: "心配の前に測る", korean: "걱정 전에 재기"),
        AIQuote(english: "Trust numbers, not panic.", simplifiedChinese: "相信数字，不信焦虑", traditionalChinese: "相信數字，不信焦慮", japanese: "不安より数字", korean: "불안보다 숫자"),
        AIQuote(english: "Less checking, more building.", simplifiedChinese: "少查后台，多做事", traditionalChinese: "少查後台，多做事", japanese: "確認より作る", korean: "확인보다 만들기"),
        AIQuote(english: "Use quota like battery.", simplifiedChinese: "像电量一样看额度", traditionalChinese: "像電量一樣看額度", japanese: "枠を電池のように", korean: "한도를 배터리처럼"),
        AIQuote(english: "Stop guessing usage.", simplifiedChinese: "别再猜用量", traditionalChinese: "別再猜用量", japanese: "使用量を推測しない", korean: "사용량 추측 그만"),
        AIQuote(english: "One glance, fewer tabs.", simplifiedChinese: "一眼看清，少开标签", traditionalChinese: "一眼看清，少開標籤", japanese: "一目でタブ減", korean: "한눈에 탭 줄이기"),
        AIQuote(english: "Signals over dashboards.", simplifiedChinese: "看信号，少逛后台", traditionalChinese: "看訊號，少逛後台", japanese: "画面より信号", korean: "화면보다 신호"),
        AIQuote(english: "Cost visible, mind quiet.", simplifiedChinese: "成本可见，心安静", traditionalChinese: "成本可見，心安靜", japanese: "費用が見え安心", korean: "비용 보이면 차분"),
        AIQuote(english: "Refresh facts, not anxiety.", simplifiedChinese: "刷新事实，不刷焦虑", traditionalChinese: "刷新事實，不刷焦慮", japanese: "不安でなく事実更新", korean: "불안 말고 사실 갱신"),
        AIQuote(english: "A small meter beats a login.", simplifiedChinese: "小仪表胜过再登录", traditionalChinese: "小儀表勝過再登入", japanese: "小さな計器で十分", korean: "작은 계기가 낫다"),
        AIQuote(english: "Track limits before they bite.", simplifiedChinese: "限额咬人前先看到", traditionalChinese: "限額咬人前先看到", japanese: "限界前に見る", korean: "한계 전에 보기"),
        AIQuote(english: "Good prompts save spend.", simplifiedChinese: "好提示能省成本", traditionalChinese: "好提示能省成本", japanese: "良い指示は節約", korean: "좋은 프롬프트 절약"),
        AIQuote(english: "Visible usage restores calm.", simplifiedChinese: "用量可见，焦虑下降", traditionalChinese: "用量可見，焦慮下降", japanese: "使用量が見え安心", korean: "사용량 보이면 안심"),
        AIQuote(english: "Attention is the rare quota.", simplifiedChinese: "注意力才是稀缺额度", traditionalChinese: "注意力才是稀缺額度", japanese: "注意こそ希少枠", korean: "주의력이 희소한도"),
        AIQuote(english: "Every token should have a job.", simplifiedChinese: "每个 token 都要有任务", traditionalChinese: "每個 token 都要有任務", japanese: "各トークンに役目", korean: "모든 토큰에 역할"),
        AIQuote(english: "The best UI lowers pulse.", simplifiedChinese: "好 UI 会降低心率", traditionalChinese: "好 UI 會降低心率", japanese: "良いUIは心を鎮める", korean: "좋은 UI는 맥박 낮춤"),
        AIQuote(english: "Save clicks, save focus.", simplifiedChinese: "少点几次，多些专注", traditionalChinese: "少點幾次，多些專注", japanese: "クリック減らし集中", korean: "클릭 줄이고 집중"),
        AIQuote(english: "Good monitors feel invisible.", simplifiedChinese: "好监控像不存在", traditionalChinese: "好監控像不存在", japanese: "良い監視は見えない", korean: "좋은 모니터는 조용"),
        AIQuote(english: "Budget seen is budget owned.", simplifiedChinese: "看见预算，就能掌控", traditionalChinese: "看見預算，就能掌控", japanese: "見える予算は扱える", korean: "보이는 예산은 통제"),
        AIQuote(english: "Fast feedback prevents panic.", simplifiedChinese: "快反馈能防恐慌", traditionalChinese: "快回饋能防恐慌", japanese: "早い反応は安心", korean: "빠른 피드백은 안심"),
        AIQuote(english: "Know capacity before sprinting.", simplifiedChinese: "冲刺前先看容量", traditionalChinese: "衝刺前先看容量", japanese: "走る前に容量確認", korean: "달리기 전 용량 확인"),
        AIQuote(english: "Make hidden costs measurable.", simplifiedChinese: "把隐藏成本变数字", traditionalChinese: "把隱藏成本變數字", japanese: "隠れ費用を測る", korean: "숨은 비용을 측정"),
        AIQuote(english: "Quiet tools respect flow.", simplifiedChinese: "安静工具尊重心流", traditionalChinese: "安靜工具尊重心流", japanese: "静かな道具が流れを守る", korean: "조용한 도구는 흐름 보호"),
        AIQuote(english: "AI helps, you decide.", simplifiedChinese: "AI 辅助，你来决定", traditionalChinese: "AI 輔助，你來決定", japanese: "AIは助け、人が決める", korean: "AI는 돕고 사람이 결정"),
        AIQuote(english: "Search once, think twice.", simplifiedChinese: "搜一次，想两次", traditionalChinese: "搜一次，想兩次", japanese: "一度探し二度考える", korean: "한 번 찾고 두 번 생각"),
        AIQuote(english: "Precision saves tokens.", simplifiedChinese: "精准会节省 token", traditionalChinese: "精準會節省 token", japanese: "精度はトークン節約", korean: "정확함은 토큰 절약"),
        AIQuote(english: "Clear limits, clear work.", simplifiedChinese: "边界清楚，工作清楚", traditionalChinese: "邊界清楚，工作清楚", japanese: "限界明確、仕事明確", korean: "한계가 선명하면 일도 선명"),
        AIQuote(english: "Enough quota, enough calm.", simplifiedChinese: "额度够，心就稳", traditionalChinese: "額度夠，心就穩", japanese: "枠が足りれば安心", korean: "한도 충분하면 안정"),
        AIQuote(english: "Watch the edge, not the noise.", simplifiedChinese: "看边界，不看噪声", traditionalChinese: "看邊界，不看噪聲", japanese: "雑音より境界", korean: "소음보다 경계"),
        AIQuote(english: "Let routine checks disappear.", simplifiedChinese: "让例行检查消失", traditionalChinese: "讓例行檢查消失", japanese: "定例確認を消す", korean: "반복 확인을 없애기"),
        AIQuote(english: "Use machines for tedious checks.", simplifiedChinese: "让机器处理繁琐检查", traditionalChinese: "讓機器處理繁瑣檢查", japanese: "面倒な確認は機械へ", korean: "번거로운 확인은 기계에게"),
        AIQuote(english: "Metrics turn worry into action.", simplifiedChinese: "指标把焦虑变行动", traditionalChinese: "指標把焦慮變行動", japanese: "指標は不安を行動へ", korean: "지표는 걱정을 행동으로"),
        AIQuote(english: "Let data answer first.", simplifiedChinese: "先让数据回答", traditionalChinese: "先讓數據回答", japanese: "まずデータに答えさせる", korean: "먼저 데이터가 답하게"),
        AIQuote(english: "Calm systems show their state.", simplifiedChinese: "冷静系统会显示状态", traditionalChinese: "冷靜系統會顯示狀態", japanese: "良い系は状態を示す", korean: "좋은 시스템은 상태를 보여줌"),
        AIQuote(english: "Good tools reduce reloads.", simplifiedChinese: "好工具减少刷新", traditionalChinese: "好工具減少刷新", japanese: "良い道具は更新を減らす", korean: "좋은 도구는 새로고침 감소"),
        AIQuote(english: "Fresh context beats panic.", simplifiedChinese: "新上下文胜过慌张", traditionalChinese: "新上下文勝過慌張", japanese: "新しい文脈は焦りに勝つ", korean: "새 맥락은 당황을 이김"),
        AIQuote(english: "Invisible costs create stress.", simplifiedChinese: "隐形成本最让人紧张", traditionalChinese: "隱形成本最讓人緊張", japanese: "見えない費用は不安", korean: "보이지 않는 비용은 불안"),
        AIQuote(english: "A calm quota is leverage.", simplifiedChinese: "可控额度就是杠杆", traditionalChinese: "可控額度就是槓桿", japanese: "落ち着いた枠は力", korean: "차분한 한도는 힘"),
        AIQuote(english: "Use AI, keep the wheel.", simplifiedChinese: "用 AI，但握住方向", traditionalChinese: "用 AI，但握住方向", japanese: "AIを使い舵は持つ", korean: "AI를 쓰되 방향은 쥔다"),
        AIQuote(english: "Monitor gently, ship faster.", simplifiedChinese: "温和监控，交付更快", traditionalChinese: "溫和監控，交付更快", japanese: "穏やかに監視し速く出す", korean: "부드럽게 감시하고 빠르게"),
        AIQuote(english: "Model output needs judgment.", simplifiedChinese: "模型答案仍需判断", traditionalChinese: "模型答案仍需判斷", japanese: "モデル出力に判断を", korean: "모델 출력엔 판단 필요"),
        AIQuote(english: "Automation holds the line.", simplifiedChinese: "让自动化守住边界", traditionalChinese: "讓自動化守住邊界", japanese: "自動化が境界を守る", korean: "자동화가 경계를 지킴"),
        AIQuote(english: "Small prompts, clear results.", simplifiedChinese: "小提示，清结果", traditionalChinese: "小提示，清結果", japanese: "短い指示、明確な結果", korean: "짧은 프롬프트, 선명한 결과"),
        AIQuote(english: "Ask better, spend less.", simplifiedChinese: "问得更准，花得更少", traditionalChinese: "問得更準，花得更少", japanese: "よく問えば少なく使う", korean: "잘 물으면 덜 쓴다"),
        AIQuote(english: "Logs calm anxious systems.", simplifiedChinese: "日志让系统安静", traditionalChinese: "日誌讓系統安靜", japanese: "ログは不安を鎮める", korean: "로그는 시스템을 진정"),
        AIQuote(english: "Quota saved is focus kept.", simplifiedChinese: "省下额度，留住专注", traditionalChinese: "省下額度，留住專注", japanese: "枠を節約し集中を守る", korean: "한도 아끼면 집중 유지"),
        AIQuote(english: "The best alert is early.", simplifiedChinese: "最好的提醒要更早", traditionalChinese: "最好的提醒要更早", japanese: "良い通知は早く届く", korean: "좋은 알림은 일찍 온다"),
        AIQuote(english: "Track usage like runway.", simplifiedChinese: "像跑道一样看余量", traditionalChinese: "像跑道一樣看餘量", japanese: "滑走路のように余裕を見る", korean: "활주로처럼 여유 보기"),
        AIQuote(english: "No surprise 429 today.", simplifiedChinese: "今天少见 429", traditionalChinese: "今天少見 429", japanese: "今日は429を避ける", korean: "오늘은 429 줄이기"),
        AIQuote(english: "A meter beats another login.", simplifiedChinese: "小仪表胜过再登录", traditionalChinese: "小儀表勝過再登入", japanese: "計器は再ログインに勝つ", korean: "계기가 재로그인보다 낫다"),
    ]
}

final class AIQuoteStore: ObservableObject {
    static let shared = AIQuoteStore()
    static let defaultsKey = "aiQuoteIndex"

    @Published private(set) var currentIndex: Int {
        didSet {
            defaults.set(currentIndex, forKey: Self.defaultsKey)
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedIndex = defaults.integer(forKey: Self.defaultsKey)
        if AIQuoteLibrary.quotes.isEmpty {
            currentIndex = 0
        } else {
            currentIndex = storedIndex % AIQuoteLibrary.quotes.count
        }
    }

    func advance() {
        guard !AIQuoteLibrary.quotes.isEmpty else { return }
        currentIndex = (currentIndex + 1) % AIQuoteLibrary.quotes.count
    }

    func currentQuoteText(language: AppLanguage = AppLanguageStore.shared.language) -> String {
        guard !AIQuoteLibrary.quotes.isEmpty else { return "" }
        return AIQuoteLibrary.quotes[currentIndex].text(language: language)
    }
}
