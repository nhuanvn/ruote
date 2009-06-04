
#
# Testing Ruote (OpenWFEru)
#
# Wed Jun  3 21:52:09 JST 2009
#

require File.dirname(__FILE__) + '/base'

require 'ruote/part/null_participant'


class FtOnCancelTest < Test::Unit::TestCase
  include FunctionalBase

  def test_on_cancel

    pdef = Ruote.process_definition do
      sequence :on_cancel => 'catcher' do
        nemo
      end
    end

    @engine.register_participant :nemo, Ruote::NullParticipant

    @engine.register_participant :catcher do
      @tracer << "caught\n"
    end

    #noisy

    wfid = @engine.launch(pdef)
    wait_for(wfid)

    @engine.cancel_process(wfid)
    wait_for(wfid)

    assert_equal 'caught', @tracer.to_s
  end

  def test_on_cancel_missing_handler

    pdef = Ruote.process_definition do
      sequence :on_cancel => 'nada' do
        nemo
      end
    end

    @engine.register_participant :nemo, Ruote::NullParticipant

    #noisy

    wfid = @engine.launch(pdef)
    wait_for(wfid)

    @engine.cancel_process(wfid)
    wait_for(wfid)

    ps = @engine.process_status(wfid)
    assert (ps == nil), "process_status not nil"
      # process has terminated anyway

    assert_equal 1, logger.log.select { |e| e[0] == :errors }.size
      # 1 error
  end
end

