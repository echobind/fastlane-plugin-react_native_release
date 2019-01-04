describe Fastlane::Actions::ReactNativeReleaseAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The react_native_release plugin is working!")

      Fastlane::Actions::ReactNativeReleaseAction.run(nil)
    end
  end
end
